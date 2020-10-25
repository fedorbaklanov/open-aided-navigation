function [srfId] = getSubrameId(subframe)
    mask = uint32(hex2dec('7'));
    srfId = bitand(bitshift(subframe(2),-8),mask);
end

