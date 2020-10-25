function [integStatFlag] = parseGpsTLM(subframe)
    mask = uint32(1);
    integStatFlag = bitand(bitshift(subframe(1),-7),mask);
end

