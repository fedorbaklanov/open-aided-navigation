function [euler_nb] = lib_dcmToEuler(R_nb)
%lib_dcmToEuler Compute Euler angles from rotation matrix.
%   Detailed explanation goes here
    euler_nb = zeros(3,1);
    euler_nb(1) = atan2(R_nb(3,2), R_nb(3,3));
    euler_nb(2) = asin(-R_nb(3,1));
    euler_nb(3) = atan2(R_nb(2,1), R_nb(1,1));
end
