function [x_dot] = lib_insOdeEcef(x,omega_is,f_s)
    %lib_insOdeEcef Computation of the right part of INS ODE mechanization
    %in ECEF coordinates.
    %
    %   ECEF coordinates -- states 1 to 3
    %   ECEF velocity vector -- states 4 to 6
    %   Orientation quaternion (sensor to ECEF frame) -- states 7 to 10

    x_dot = zeros(10,1);

    C_es = lib_quatToDcm(x(7:10));

    % Derivative of position
    x_dot(1:3) = x(4:6);

    % Derivative of velocity
    x_dot(4:6) = lib_gravityEcefJ2(x(1:3),Wgs84);
    x_dot(4:6) = x_dot(4:6) + C_es * f_s;
    x_dot(4:6) = x_dot(4:6) + [2 * Wgs84.omega_ie * x(5); -2 * Wgs84.omega_ie * x(4); 0];

    % Derivative of quaternion
    x_dot(7:10) = lib_quatMult(x(7:10), [0; omega_is]);
    x_dot(7:10) = x_dot(7:10) - [ -Wgs84.omega_ie * x(10);...
                                  -Wgs84.omega_ie * x(9);...
                                   Wgs84.omega_ie * x(8);...
                                   x(7) * Wgs84.omega_ie];
    x_dot(7:10) = 0.5 * x_dot(7:10);
end
