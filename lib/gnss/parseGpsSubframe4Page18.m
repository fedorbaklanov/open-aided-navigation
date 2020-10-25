function [subframe4page18Data] = parseGpsSubframe4Page18(subframe)
    subframe4page18Data = DataGpsSubframe4Page18;
    
    mask = uint32(hex2dec('ff')); % 8 lower bits
    subframe4page18Data.alpha0 = typecast(cast(bitand(bitshift(subframe(3),-14),mask),'uint8'),'int8');
    subframe4page18Data.alpha1 = typecast(cast(bitand(bitshift(subframe(3),-6),mask),'uint8'),'int8');
    subframe4page18Data.alpha2 = typecast(cast(bitand(bitshift(subframe(4),-22),mask),'uint8'),'int8');
    subframe4page18Data.alpha3 = typecast(cast(bitand(bitshift(subframe(4),-14),mask),'uint8'),'int8');
    subframe4page18Data.beta0 = typecast(cast(bitand(bitshift(subframe(4),-6),mask),'uint8'),'int8');
    subframe4page18Data.beta1 = typecast(cast(bitand(bitshift(subframe(5),-22),mask),'uint8'),'int8');
    subframe4page18Data.beta2 = typecast(cast(bitand(bitshift(subframe(5),-14),mask),'uint8'),'int8');
    subframe4page18Data.beta3 = typecast(cast(bitand(bitshift(subframe(5),-6),mask),'uint8'),'int8');
end

