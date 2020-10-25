classdef SbasInfoHandler   
    properties %(Access = private)
        data = repmat(SbasData,1,ConfGnssEng.MAX_SV_SBAS_INFO);
    end
    
    methods        
        function obj = handleSubframe(obj,subframe,svId)
            global navState;
            
            crc1 = calcSbasCrc(subframe); % calculate crc from received data
            crc2 = extractSbasCrc(subframe); % extract received crc from the message
            
            if crc1 == crc2
                slotNum = getDbSlot(obj,svId);
                if slotNum > 0
                    % there is a place to save data from this satellite
                    msgId = getSbasMsgId(subframe);    
                    switch msgId
                        case 0
                            disp('SBAS Msg 0');
                        case 1
                            obj.data(slotNum).svId = svId;
                            [obj.data(slotNum).svList,obj.data(slotNum).svListIODP] =...
                                obj.handlePrnMask(subframe);
                        case 2
                            obj = obj.handleMsg2to5(2,subframe,slotNum,navState);
                        case 3
                            obj = obj.handleMsg2to5(3,subframe,slotNum,navState);
                        case 4
                            obj = obj.handleMsg2to5(4,subframe,slotNum,navState);
                        case 5
                            obj = obj.handleMsg2to5(5,subframe,slotNum,navState);
                        case 6
                            disp('SBAS Msg 6');
                        case 18
                            disp('SBAS Msg 18');
                        case 24
                            disp('SBAS Msg 24');
                        case 25
                            disp('SBAS Msg 25');
                        case 26
                            disp('SBAS Msg 26');
                        otherwise
                            disp('SBAS Msg UNKNOWN');
                    end
                else
                    % database is full, have to reject data, do nothing
                end
            else
                % crc check failed, ignore message
                disp('SBAS CRC failure!');
            end
        end
        
        function [sbasFc,status] = getFastCorr(obj,svId)
            status = false;
            sbasFc = SbasFc;
            sbasFcTmp = SbasFc;
            for i=1:1:ConfGnssEng.MAX_SV_SBAS_INFO
                if obj.data(i).svId > 0 && obj.data(i).svListIODP ~= 255
                    svSlot = obj.getSvSlot(obj.data(i),svId);
                    if svSlot > 0
                        sbasFcTmp = obj.data(i).fcData(svSlot);
                    end
                    if sbasFc.fcSet && sbasFcTmp.fcSet
                        if sbasFc.t_of < sbasFcTmp.t_of
                            sbasFc = sbasFcTmp; % we take the most recent correction
                        end
                    elseif sbasFcTmp.fcSet
                        sbasFc = sbasFcTmp;
                        status = true;
                    else
                        % continue
                    end
                end
            end
        end
    end
    
    methods (Access = private)
        function slotNum = getDbSlot(obj,svId)
            slotNum = 0; % 0 is invalid value
            for i=1:1:ConfGnssEng.MAX_SV_SBAS_INFO
                if obj.data(i).svId == 0 || obj.data(i).svId == svId
                    % we return index of the first free slot, or a slot where
                    % data from this SBAS SV is already stored
                    slotNum = i;
                    break;
                end
            end
        end
        
        function [svList,IODP] = handlePrnMask(~,msg1)
            svList = uint8(zeros(1,51));
            i = 1;
            sbasSvNum = 1;
            % loop throught data words in subframe
            for j=1:1:8
                if j==1
                    bitsToCheck = 18; % 32 - preamble - msgId
                    bitInd = 18;
                elseif 2 <= j && j <= 7
                    bitsToCheck = 32;
                    bitInd = 32;
                else % j == 8
                    bitsToCheck = 2;
                    bitInd = 32;
                end
                dataWord = msg1(j);                
                while bitsToCheck > 0
                    if bitget(dataWord,bitInd) > 0
                        if 1 <= sbasSvNum && sbasSvNum <= 32
                            % GPS
                            svList(i) = sbasSvNum; % 1 to 32 is u-blox svId range for GPS SVs
                        elseif 62 <= sbasSvNum && sbasSvNum <= 97
                            % Galileo
                            svList(i) = sbasSvNum - 62 + 211; % According to SBAS ICD Gal SVs ID are in a range 62 to 119, we map it to u-blox svIds whose range is 211 to 246
                        elseif 38 <= sbasSvNum && sbasSvNum <= 61
                            % GLONASS
                            svList(i) = sbasSvNum - 38 + 65; % According to SBAS ICD Gal SVs ID are in a range 38 to 61, we map it to u-blox svIds whose range is 65 to 96
                        else
                            % do nothing
                        end
                        i = i + 1; % increment SV counter
                    end
                    sbasSvNum = sbasSvNum + 1; % increment SBAS SV ID
                    bitInd = bitInd - 1; % decrement bit index
                    bitsToCheck = bitsToCheck - 1; % decrement number of bits to check
                    if i > 51
                        break; % SBAS shall transmit corrections for no more than 51 SVs simultaneously
                    end
                end                
                if i > 51
                    break; % SBAS shall transmit corrections for no more than 51 SVs simultaneously
                end
            end
            IODP = uint8(bitand(bitshift(msg1(8),-30),uint32(hex2dec('3'))));
        end
        
        function [obj] = handleMsg2to5(obj,msgNum,msg,slotNum,navState)
            if obj.data(slotNum).svList(1) ~= 0
                % There is at least 1 entry in SV list
                errorFlag = false;
                switch msgNum
                    case 2
                        svIndOffset = 0;
                        svIndMax = 13;
                    case 3
                        svIndOffset = 13;
                        svIndMax = 13;
                    case 4
                        svIndOffset = 26;
                        svIndMax = 13;
                    case 5
                        svIndOffset = 39;
                        svIndMax = 12;
                    otherwise
                        errorFlag = true;                        
                end
                svInd = 1;
                while svInd <= svIndMax && obj.data(slotNum).svList(svInd) ~= 0 && ~errorFlag
                    obj.data(slotNum).UDRE(svInd+svIndOffset) = obj.extractUdre(svInd,msg,msgNum);
                    if obj.data(slotNum).UDRE(svInd+svIndOffset) < 14
                        fc = obj.extractFc(svInd,msg);
                        prcTmp = obj.decodePrc(fc);
                        if obj.data(slotNum).fcData(svInd+svIndOffset).fcSet
                           obj.data(slotNum).fcData(svInd+svIndOffset).rrc =...
                               (prcTmp - obj.data(slotNum).fcData(svInd+svIndOffset).prc) / (floor(navState.gpsTow) - obj.data(slotNum).fcData(svInd+svIndOffset).t_of);
                           obj.data(slotNum).fcData(svInd+svIndOffset).rrcValid = true;
                        end
                        obj.data(slotNum).fcData(svInd+svIndOffset).prc = prcTmp;
                        obj.data(slotNum).fcData(svInd+svIndOffset).fcSet = true;
                        obj.data(slotNum).fcData(svInd+svIndOffset).t_of = floor(navState.gpsTow);
                        obj.data(slotNum).fcData(svInd+svIndOffset).IODP = uint8(bitand(bitshift(msg(1),-14),uint32(hex2dec('3'))));
                    else
                        % invalidate fast correction
                        obj.data(slotNum).fcData(svInd+svIndOffset) = SbasFc;
                    end
                    svInd = svInd + 1;
                end
            else
                % SV list empty, do nothing
            end
        end
        
        function [fc] = extractFc(~,fcInd,subframe)
            fc = 0;
            switch fcInd
                case 1
                    fc = uint16(bitand(bitshift(subframe(1),-2),uint32(hex2dec('fff'))));
                case 2
                    fc = bitshift(uint16(bitand(subframe(1),uint32(hex2dec('3')))),10);
                    fc = bitor(fc,uint16(bitand(bitshift(subframe(2),-22),uint32(hex2dec('3ff')))));
                case 3
                    fc = uint16(bitand(bitshift(subframe(2),-10),uint32(hex2dec('fff'))));
                case 4
                    fc = bitshift(uint16(bitand(subframe(2),uint32(hex2dec('3ff')))),2);
                    fc = bitor(fc,uint16(bitand(bitshift(subframe(3),-30),uint32(hex2dec('3')))));
                case 5
                    fc = uint16(bitand(bitshift(subframe(3),-18),uint32(hex2dec('fff'))));
                case 6
                    fc = uint16(bitand(bitshift(subframe(3),-6),uint32(hex2dec('fff'))));
                case 7
                    fc = bitshift(uint16(bitand(subframe(3),uint32(hex2dec('3f')))),6);
                    fc = bitor(fc,uint16(bitand(bitshift(subframe(4),-26),uint32(hex2dec('3f')))));
                case 8
                    fc = uint16(bitand(bitshift(subframe(4),-14),uint32(hex2dec('fff'))));
                case 9
                    fc = uint16(bitand(bitshift(subframe(4),-2),uint32(hex2dec('fff'))));
                case 10
                    fc = bitshift(uint16(bitand(subframe(4),uint32(hex2dec('3')))),10);
                    fc = bitor(fc,uint16(bitand(bitshift(subframe(5),-22),uint32(hex2dec('3ff')))));
                case 11
                    fc = uint16(bitand(bitshift(subframe(5),-10),uint32(hex2dec('fff'))));
                case 12
                    fc = bitshift(uint16(bitand(subframe(5),uint32(hex2dec('3ff')))),2);
                    fc = bitor(fc,uint16(bitand(bitshift(subframe(6),-30),uint32(hex2dec('3')))));
                case 13
                    fc = uint16(bitand(bitshift(subframe(6),-18),uint32(hex2dec('fff'))));
                otherwise
                    % do nothing
            end
        end

        function [obj] = handleMsg25(obj,msg,slotNum)
            % consider velocity code
            if bitget(msg(1),17) > 0
                obj = handleMsg25vc1(msg);
            else
                obj = handleMsg25vc0(msg);
            end
        end

        function [obj] = handleMsg25vc0(obj,msg)
        end

        function [obj] = handleMsg25vc1(obj,msg)
        end

        function [udre] = extractUdre(~,udreInd,subframe,msgNum)
            lWord = typecast(subframe(5:6),'uint64');
            if msgNum == 5
                offsetInWord = 2;
            else
                offsetInWord = 14;
            end                                
            if msgNum ~= 5 && udreInd == 13
                udre = uint8(bitshift(bitand(lWord,uint64(hex2dec('3'))),2));
                udre = bitor(udre,uint8(bitand(bitshift(subframe(7),-30),uint32(hex2dec('3')))));
            else
                udre = uint8(bitand(bitshift(lWord,-(64-offsetInWord-4*udreInd)),uint64(hex2dec('f'))));
            end
        end
        
        function prc = decodePrc(~,fc)
            prc = 0.125 * (double(fc) - 2048);
        end
        
        function [svSlot] = getSvSlot(~,sbasData,svId)
            svSlot = 0; % initialize with invalid value
            i = 1;
            while sbasData.svList(i) > 0 && i <= 51
                if svId == sbasData.svList(i)
                    svSlot = i;
                    break;
                elseif svId < sbasData.svList(i)
                    break;
                else
                    % continue search
                end
                i = i + 1;
            end
        end
            
    end
end

