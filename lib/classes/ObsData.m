classdef ObsData
    properties
        valid = false          % Validity flag
        type = ObsType.UNKNOWN % Observation type
        val = 0                % Observation (measurement) value
        est = 0                % Observation estimate (derived from state)
        res = 0                % Residual, i. e. val - est, used as input to Kalman filter
        var = 0                % Observation variance
    end
end

