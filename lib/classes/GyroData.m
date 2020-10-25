%% Class Name: GyroData
% This is a structure for gyroscope data.
% 
% Properties
%    logical valid - measurement validity flag
%    uint64 ttag - time tag of the data in microseconds, [us]
%    double[3] omega_is - angular rate in radians per second, [rad/s]
% $Date: November 1, 2019
% _________________________________________________________________________
classdef GyroData    
    properties
        valid = false;
        ttag = uint64(0);
        omega_is = double(zeros(3,1));
    end
end