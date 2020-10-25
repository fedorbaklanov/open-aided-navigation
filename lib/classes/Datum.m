classdef Datum
    properties (Abstract, Constant)
        a; % Semi-major axis, [m]
        f; % Flattening, [-]
        omega_ie; % Earth angular rate, [rad/s]
        b; % Semi-minor axis, [m]
        e; % Eccentricity, [-]
        e2; % Eccentricity squared, [-]
        GM; % Earth gravitational constant,[m^3/s^2]
        J2; % J2 zonal coefficient, [-]
    end
end

