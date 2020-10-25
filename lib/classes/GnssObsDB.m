classdef GnssObsDB
    properties
        obsCount = uint16(0);
        maxObsCount = uint16(3*ConfGnssEng.MAX_SIGMEAS_NUM);
        obs = repmat(GnssObs,1,3*ConfGnssEng.MAX_SIGMEAS_NUM);
    end
end

