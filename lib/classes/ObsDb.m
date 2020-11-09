classdef ObsDb
    properties (SetAccess='private', GetAccess='public')
        obsCount = 0  % Number of valid observation in the database
        capacity = 0  % Capacity of the database
        obs = ObsData % Observation array
    end

    methods
        function obj = ObsDb(maxObsCnt)
            obj.capacity = maxObsCnt;
            obj.obs = repmat(ObsData,1,maxObsCnt);
        end

        function obj = reset(obj)
            obj.obsCount = 0;
            obj.obs = repmat(ObsData,1,obj.capacity);
        end

        function [obj,res] = add(obj,type,val,est,var)
            res = false;
            nextInd = obj.obsCount + 1;
            if nextInd <= obj.capacity
                obj.obs(nextInd).type = type;
                obj.obs(nextInd).val = val;
                obj.obs(nextInd).est = est;
                obj.obs(nextInd).res = val - est;
                obj.obs(nextInd).var = var;
                obj.obs(nextInd).valid = true;
                obj.obsCount = nextInd;
                res = true;
            end
        end

        function obj = setInvalid(obj,ind)
            if ind > 0 && ind <= obj.capacity
                obj.obs(ind).valid = false;
            end
        end
    end
end

