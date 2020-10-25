function [sign] = getSignFromMsb(msb)
    if msb == uint8(1)
        sign = -1;
    else
        sign = 1;
    end
end

