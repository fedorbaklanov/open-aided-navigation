function [crc] = extractSbasCrc(msg)
    crc = bitand(bitshift(msg(8),-6),uint32(hex2dec('ffffff')));
end

