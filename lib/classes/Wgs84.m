classdef Wgs84 < Datum
    properties (Constant)
        a = 6378137.0; % Semi-major axis, [m]
        f = 1/298.257223563; % Flattening, [-]
        omega_ie = 7.292115e-5; % Earth angular rate, [rad/s]
        b = 6356752.31424518; % Semi-minor axis, [m], (1 - f) * a
        e = 8.18191908426215e-2; % First eccentricity, [-], sqrt((a^2 - b^2) / a^2)
        e2 = 6.69437999014132e-3; % First eccentricity squared, [-], (a^2 - b^2) / a^2
        GM = 3986004.418e8; % Earth gravitational constant,[m^3/s^2]
        J2 = 1.08262982136857e-3; % J2 zonal coefficient, [-]
    end
end

