function [dataId] = getGpsSubrameDataId(subframe)
    mask = uint32(hex2dec('3')); % 2 lower bits
    dataId = cast(bitand(bitshift(subframe(3),-28),mask),'uint8');
end

