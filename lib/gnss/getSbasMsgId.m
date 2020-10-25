function [msgId] = getSbasMsgId(subframe)
    msgId = uint8(bitand(bitshift(subframe(1),-18),uint32(hex2dec('3f')))); % 6 upper bits of the 2nd byte
end

