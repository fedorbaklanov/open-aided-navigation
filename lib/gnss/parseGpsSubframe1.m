function [subframe1Data] = parseGpsSubframe1(subframe)
    subframe1Data = struct('codeOnL2',uint8(0),...
                           'weekNum',uint16(0),...
                           'dataFlagL2P',uint8(0),...
                           'svAcc',uint8(0),...
                           'svHealth',uint8(0),...
                           'TGD',int8(0),...
                           'IODC',uint16(0),...
                           'toc',uint16(0),...
                           'af2',int8(0),...
                           'af1',int16(0),...
                           'af0',int32(0));
    
    mask = uint32(3); % 2 lower bits
    subframe1Data.codeOnL2 = cast(bitand(bitshift(subframe(3),-18),mask),'uint8');
    
    mask = uint32(hex2dec('3ff')); % 10 lower bits
    subframe1Data.weekNum = cast(bitand(bitshift(subframe(3),-20),mask),'uint16');
    
    mask = uint32(1); % 1 lower bit
    subframe1Data.dataFlagL2P = cast(bitand(bitshift(subframe(4),-29),mask),'uint8');
    
    mask = uint32(hex2dec('f')); % 4 lower bits
    subframe1Data.svAcc = cast(bitand(bitshift(subframe(3),-14),mask),'uint8');
    
    mask = uint32(hex2dec('3f')); % 6 lower bits
    subframe1Data.svHealth = cast(bitand(bitshift(subframe(3),-8),mask),'uint8');
    
    mask = uint32(hex2dec('ff')); % 8 lower bits
    subframe1Data.TGD = typecast(cast(bitand(bitshift(subframe(7),-6),mask),'uint8'),'int8');
    
    mask1 = uint32(3); % 2 lower bits
    mask2 = uint32(hex2dec('ff')); % 8 lower bits
    subframe1Data.IODC = cast(bitor(bitshift(bitand(bitshift(subframe(3),-6),mask1),8),...
                                        bitand(bitshift(subframe(8),-22),mask2)),...
                                  'uint16');
                              
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe1Data.toc = cast(bitand(bitshift(subframe(8),-6),mask),'uint16');
    
    mask = uint32(hex2dec('ff')); % 8 lower bits
    subframe1Data.af2 = typecast(cast(bitand(bitshift(subframe(9),-22),mask),'uint8'),'int8');
    
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe1Data.af1 = typecast(cast(bitand(bitshift(subframe(9),-6),mask),'uint16'),'int16');
    
    mask = uint32(hex2dec('3fffff')); % 22 lower bits
    tmp = cast(bitand(bitshift(subframe(10),-8),mask),'uint32');
    
    mask = uint32(0);
    
    if getSignFromMsb(bitshift(tmp,-21)) < 0
        mask = bitshift(uint32(hex2dec('3ff')),22);
    end
    
    subframe1Data.af0 = typecast(bitor(tmp,mask),'int32');
end

