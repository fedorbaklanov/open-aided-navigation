classdef OrbitDB
    properties
        valid = false;
        rcvTow = 0;
        svOrbitData = repmat(SvOrbitData,1,ConfGnssEng.MAX_SV_NUM);
    end
end

