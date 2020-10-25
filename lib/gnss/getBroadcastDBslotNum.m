function [slotNum] = getBroadcastDBslotNum(gnssId, svId)
    slotNum = 0;
    
    if gnssId == GnssId.GPS
        slotNum = svId;
    end
end

