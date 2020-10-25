classdef SbasLc    
    properties
        dPosValid = false;
        dx = 0;
        dy = 0;
        dz = 0;
        da_f0 = 0;
        dVelValid = false;
        dx_dot = 0;
        dy_dot = 0;
        dz_dot = 0;
        da_f1 = 0;
        t_LT = 0;
        t_0 = 0;
        IOD = 0;
        IODP = uint8(255); % 255 is invalid value
    end
end

