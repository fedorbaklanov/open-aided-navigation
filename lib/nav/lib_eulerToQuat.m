function [q] = lib_eulerToQuat(phi, theta, psi)
    %lib_eulerToQuat Convert Euler angles in aerospace sequence to
    %orientation quaternion that defines a transformation from sensor frame
    %to ECEF coordinate system.
    %
    %   Input parameters:
    %
    %      phi -- roll, [rad]
    %      theta -- pitch, [rad]
    %      psi -- heading, [rad]

    q = zeros(4,1);
    cos05phi   = cos(0.5 * phi);
    sin05phi   = sin(0.5 * phi);
    cos05theta = cos(0.5 * theta);
    sin05theta = sin(0.5 * theta);
    cos05psi   = cos(0.5 * psi);
    sin05psi   = sin(0.5 * psi);

    q(1) = cos05phi * cos05theta * cos05psi  +  sin05phi * sin05theta * sin05psi;
    q(2) = sin05phi * cos05theta * cos05psi  -  cos05phi * sin05theta * sin05psi;
    q(3) = cos05phi * sin05theta * cos05psi  +  sin05phi * cos05theta * sin05psi;
    q(4) = cos05phi * cos05theta * sin05psi  -  sin05phi * sin05theta * cos05psi;
end

