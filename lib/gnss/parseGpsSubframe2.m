function [subframe2Data] = parseGpsSubframe2(subframe)
    subframe2Data = struct('IODE',uint8(0),...
                           'Crs',int16(0),...
                           'dn',int16(0),...
                           'M0',int32(0),...
                           'Cuc',int16(0),...
                           'e',uint32(0),...
                           'Cus',int16(0),...
                           'sqrtA',uint32(0),...
                           'toe',uint16(0),...
                           'fitIntervalFlag',uint8(0),...
                           'AODO',uint8(0));
                       
    mask = uint32(hex2dec('ff')); % 8 lower bits
    subframe2Data.IODE = cast(bitand(bitshift(subframe(3),-22),mask),'uint8');
    
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe2Data.Crs = typecast(cast(bitand(bitshift(subframe(3),-6),mask),'uint16'),'int16');
    
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe2Data.dn = typecast(cast(bitand(bitshift(subframe(4),-14),mask),'uint16'),'int16');
    
    mask1 = uint32(hex2dec('ff')); % 8 lower bits
    mask2 = uint32(hex2dec('ffffff')); % 24 lower bits
    subframe2Data.M0 = typecast(...
                            cast(bitor(bitshift(bitand(bitshift(subframe(4),-6),mask1),24),...
                                       bitand(bitshift(subframe(5),-6),mask2)),...
                                 'uint32'),...
                            'int32');
                        
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe2Data.Cuc = typecast(cast(bitand(bitshift(subframe(6),-14),mask),'uint16'),'int16');
    
    mask1 = uint32(hex2dec('ff')); % 8 lower bits
    mask2 = uint32(hex2dec('ffffff')); % 24 lower bits
    subframe2Data.e = cast(bitor(bitshift(bitand(bitshift(subframe(6),-6),mask1),24),...
                                 bitand(bitshift(subframe(7),-6),mask2)),...
                           'uint32');
                       
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe2Data.Cus = typecast(cast(bitand(bitshift(subframe(8),-14),mask),'uint16'),'int16');

    mask1 = uint32(hex2dec('ff')); % 8 lower bits
    mask2 = uint32(hex2dec('ffffff')); % 24 lower bits
    subframe2Data.sqrtA = cast(bitor(bitshift(bitand(bitshift(subframe(8),-6),mask1),24),...
                                     bitand(bitshift(subframe(9),-6),mask2)),...
                               'uint32');
                           
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe2Data.toe = cast(bitand(bitshift(subframe(10),-14),mask),'uint16');
    
    mask = uint32(1); % one lower bit
    subframe2Data.fitIntervalFlag = cast(bitand(bitshift(subframe(10),-13),mask),'uint8');
    
    mask = uint32(hex2dec('1f')); % 5 lower bits
    subframe2Data.AODO = cast(bitand(bitshift(subframe(10),-8),mask),'uint8');
end

