function [subframe3Data] = parseGpsSubframe3(subframe)
    subframe3Data = struct('Cic',int16(0),...
                           'Omega0',int32(0),...
                           'Cis',int16(0),...
                           'i0',int32(0),...
                           'Crc',int16(0),...
                           'omega',int32(0),...
                           'dotOmega',int32(0),...
                           'IODE',uint8(0),...
                           'IDOT',int16(0));
    
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe3Data.Cic = typecast(cast(bitand(bitshift(subframe(3),-14),mask),'uint16'),'int16');
    
    mask1 = uint32(hex2dec('ff')); % 8 lower bits
    mask2 = uint32(hex2dec('ffffff')); % 24 lower bits
    subframe3Data.Omega0 = typecast(...
                                    cast(bitor(bitshift(bitand(bitshift(subframe(3),-6),mask1),24),...
                                               bitand(bitshift(subframe(4),-6),mask2)),...
                                         'uint32'),...
                                    'int32');
                        
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe3Data.Cis = typecast(cast(bitand(bitshift(subframe(5),-14),mask),'uint16'),'int16');
    
    mask1 = uint32(hex2dec('ff')); % 8 lower bits
    mask2 = uint32(hex2dec('ffffff')); % 24 lower bits
    subframe3Data.i0 = typecast(...
                                cast(bitor(bitshift(bitand(bitshift(subframe(5),-6),mask1),24),...
                                                    bitand(bitshift(subframe(6),-6),mask2)),...
                                     'uint32'),...
                                'int32');
                       
    mask = uint32(hex2dec('ffff')); % 16 lower bits
    subframe3Data.Crc = typecast(cast(bitand(bitshift(subframe(7),-14),mask),'uint16'),'int16');

    mask1 = uint32(hex2dec('ff')); % 8 lower bits
    mask2 = uint32(hex2dec('ffffff')); % 24 lower bits
    subframe3Data.omega = typecast(...
                                   cast(bitor(bitshift(bitand(bitshift(subframe(7),-6),mask1),24),...
                                              bitand(bitshift(subframe(8),-6),mask2)),...
                                        'uint32'),...
                                   'int32');
                           
    mask = uint32(hex2dec('ffffff')); % 24 lower bits
    tmp = cast(bitand(bitshift(subframe(9),-6),mask),'uint32');
    
    mask = uint32(0);
    
    if getSignFromMsb(bitshift(tmp,-23)) < 0
        mask = bitshift(uint32(hex2dec('ff')),24);
    end
    
    subframe3Data.dotOmega = typecast(bitor(tmp,mask),'int32');
                               
                               
    mask = uint32(hex2dec('ff')); % 8 lower bits
    subframe3Data.IODE = cast(bitand(bitshift(subframe(10),-22),mask),'uint8');
    
    mask = uint32(hex2dec('3fff')); % 14 lower bits
    tmp = cast(bitand(bitshift(subframe(10),-8),mask),'uint32');
    
    mask = uint32(0);
    
    if getSignFromMsb(bitshift(tmp,-13)) < 0
        mask = bitshift(uint32(hex2dec('3')),14);
    end
    
    subframe3Data.IDOT = typecast(cast(bitor(tmp,mask),'uint16'),'int16');
end

