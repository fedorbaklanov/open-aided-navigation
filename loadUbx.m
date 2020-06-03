function [ubxMsg] = loadUbx(filename)
    ubxMsg = {};
    reservedLen = 0;
    usedLen = 0;
    
    fid = fopen(filename,'r');
    if fid == -1
        disp('Cannot open the file!');
    else
        syncChar1 = uint8(181);
        syncChar2 = uint8(98);
        EOF = false;
        while EOF == false
            char1 = fread(fid,1,'*uint8');
            char2 = fread(fid,1,'*uint8');
            if isempty(char1) || isempty(char2)
                EOF = true;
            else
                if char1 == syncChar1 && char2 == syncChar2
                    buf1 = fread(fid,4,'*uint8');
                    
                    if length(buf1) == 4
                        msg.class = buf1(1);
                        msg.id = buf1(2);
                        msg.len = bitor(bitshift(uint16(buf1(4)),8),uint16(buf1(3)));
                        
                        buf2 = fread(fid,msg.len+2,'*uint8');
                        
                        if length(buf2) == msg.len+2
                            msg.payload = buf2(1:end-2);
                            msg.crc = buf2(end-1:end);
                            usedLen = usedLen + 1;
                            
                            if usedLen > reservedLen
                                ubxMsg = [ubxMsg,cell(1,1000)];
                                reservedLen = reservedLen + 1000;
                            end
                            
                            ubxMsg{usedLen} = msg;
                        else
                            EOF = true;
                        end
                    else
                        EOF = true;
                    end
                end
            end
        end
        
        if usedLen > 0
            ind = find(cellfun(@isempty,ubxMsg));
            ubxMsg(ind) = [];
        end
        fclose(fid);
    end
end

