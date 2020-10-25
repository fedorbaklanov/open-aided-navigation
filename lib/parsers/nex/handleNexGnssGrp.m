function handleNexGnssGrp(nexGnssMsg)
    global gnssMeasDb;
    global isNewEpoch;

    switch nexGnssMsg.msgType
        case hex2dec('0')
            gnssMeas = parseNexGnssRaw(nexGnssMsg);
            gnssMeasDb = gnssMeasDb.addData(gnssMeas, SensorType.GNSS_RAW);
            isNewEpoch = true;
        case hex2dec('1')
            navMsg = parseNexGnssNav(nexGnssMsg);

            switch navMsg.navMsgType
                case 0
                    msgType = 0;
                case 1
                    % GPS broadcast message decoded from L1
                    slotNum = getBroadcastDBslotNum(GnssId.GPS, navMsg.svId);
                    handleGpsSubframe(swapbytes(typecast(navMsg.data,'uint32')), slotNum);
                case 2
                    msgType = 0;
                case 3
                    msgType = 0;
                case 4
                    msgType = 0;
                otherwise
                    msgType = 0;
            end
        otherwise
            % do nothing
    end
end

