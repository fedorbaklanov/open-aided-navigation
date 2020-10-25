function [svId] = getGpsSubrameSvId(subframe)
    mask = uint32(hex2dec('3f')); % 6 lower bits
    svId = cast(bitand(bitshift(subframe(3),-22),mask),'uint8');
end

