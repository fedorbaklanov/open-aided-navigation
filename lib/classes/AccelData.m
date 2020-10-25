%% Class Name: AccelData
% This is a structure for accelerometer data.
% 
% Properties
%    logical valid - measurement validity flag
%    double ttag - time tag of the data in microseconds, [us]
%    double[3] f_b - specific force in meters per second squared, [m/s^2]
% $Date: November 1, 2019
% _________________________________________________________________________
classdef AccelData    
    properties
        valid = false;
        ttag = uint64(0);
        f_b = double(zeros(3,1));
    end
end