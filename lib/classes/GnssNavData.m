classdef GnssNavData  
    properties
        valid = false;
        ttag = uint64(0);
        utcTime = uint64(0);
        lat = 0;
        lon = 0;
        height = 0;
        hAcc = 0;
        vAcc = 0;
    end
end

