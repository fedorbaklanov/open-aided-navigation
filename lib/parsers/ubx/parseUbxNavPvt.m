function [PVT] = parseUbxNavPvt(ubxNavMsg)
    PVT.POS_lambda = NaN;
    PVT.POS_phi = NaN;
    PVT.POS_h = NaN;
    PVT.UTC.year = NaN;
    PVT.UTC.month = NaN;
    PVT.UTC.day = NaN;
    PVT.UTC.hour = NaN;
    PVT.UTC.min = NaN;
    PVT.UTC.sec = NaN;
    
    if ubxNavMsg.len == 92
        % check that time is valid
        if bitget(ubxNavMsg.payload(12),2) > 0
            PVT.POS_lambda = pi/180 * (1e-7 * cast(typecast(ubxNavMsg.payload(25:28),'int32'),'double'));
            PVT.POS_phi = pi/180 * (1e-7 * cast(typecast(ubxNavMsg.payload(29:32),'int32'),'double'));
            PVT.POS_h = 1e-3 * cast(typecast(ubxNavMsg.payload(33:36),'int32'),'double');
            PVT.UTC.year = cast(typecast(ubxNavMsg.payload(5:6),'uint16'),'double');
            PVT.UTC.month = cast(ubxNavMsg.payload(7),'double');
            PVT.UTC.day = cast(ubxNavMsg.payload(8),'double');
            PVT.UTC.hour = cast(ubxNavMsg.payload(9),'double');
            PVT.UTC.min = cast(ubxNavMsg.payload(10),'double');
            PVT.UTC.sec = cast(ubxNavMsg.payload(11),'double');
        end
    end
end

