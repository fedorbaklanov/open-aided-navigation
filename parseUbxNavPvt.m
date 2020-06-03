function [PVT] = parseUbxNavPvt(ubxNavMsg)
    PVT.POS_lambda = NaN;
    PVT.POS_phi = NaN;
    PVT.POS_h = NaN;
    
    if ubxNavMsg.len == 92
        PVT.POS_lambda = pi/180 * (1e-7 * cast(typecast(ubxNavMsg.payload(25:28),'int32'),'double'));
        PVT.POS_phi = pi/180 * (1e-7 * cast(typecast(ubxNavMsg.payload(29:32),'int32'),'double'));
        PVT.POS_h = 1e-3 * cast(typecast(ubxNavMsg.payload(33:36),'int32'),'double');
    end
end

