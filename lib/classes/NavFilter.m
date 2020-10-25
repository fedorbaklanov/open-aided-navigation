classdef NavFilter
    properties (Abstract, SetAccess='private', GetAccess='public')
        x;  % total state vector
        dx; % error state vector
        P;  % error covariance matrix
    end
    properties (SetAccess='protected', GetAccess='public')
        mode; % filter mode (idle, init, or running)
        filTtag; % filter solution system time, [us]
    end

    methods (Abstract)
        [obj] = reset(obj);
        [obj] = setMode(obj,filterMode);
        [obj,res] = checkMeas(obj,measDb);
        [obj,res] = initState(obj,measDb);
        [obj,res] = initCov(obj);
        [obj,res] = propState(obj,measDb);
        [obj,res] = propCov(obj,measDb);
        [obj,res] = measUpdate(obj,measDb);
        [obj,res] = correctState(obj);
    end

    methods
        function x_out = getState(obj)
            x_out = obj.x;
        end

        function P_out = getCov(obj)
            P_out = obj.P;
        end

        function mode_out = getMode(obj)
            mode_out = obj.mode;
        end
    end
end

