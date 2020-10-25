function [antiSpoofFlag, alertFlag] = parseGpsHOW(subframe)
    mask = uint32(1);
    antiSpoofFlag = bitand(bitshift(subframe(2), -11), mask);
    alertFlag = bitand(bitshift(subframe(2), -12), mask);
end

