classdef GnssLsqFilter < NavFilter
    properties (SetAccess='private', GetAccess='public')
        x;  % total state vector
        dx; % error state vector
        P;  % error covariance matrix
        navState; % persistant auxiliary navigation data
        orbitDb; % auxiliary orbit data
    end

    properties (Access='private',Constant)
        stateLen = 8;
        errorStateLen = 8;
    end

    methods
        function [obj] = GnssLsqFilter()
            obj.navState = NavState;
            obj = reset(obj);
        end

        function [obj] = reset(obj)
            obj.x = zeros(obj.stateLen,1);
            obj.dx = zeros(obj.errorStateLen,1);
            obj.P = eye(obj.errorStateLen,obj.errorStateLen);
            obj.mode = FilterMode.IDLE;
            obj.filTtag = uint64(0);
        end

        function [obj] = setMode(obj,filterMode)
            switch filterMode
                case FilterMode.IDLE
                    obj.mode = FilterMode.IDLE;
                case FilterMode.INIT
                    obj.mode = FilterMode.INIT;
                case FilterMode.RUNNING
                    obj.mode = FilterMode.RUNNING;
                otherwise
                    % do nothing
            end
        end

        function [obj,res] = checkMeas(obj,measDb)
            if measDb.valid && measDb.numMeas > 3
                obj = obj.setMode(FilterMode.RUNNING);
            else
                obj = obj.setMode(FilterMode.IDLE);
            end
            res = true;
        end

        function [obj,res] = initState(obj,measDb)
            res = true;
        end

        function [obj,res] = initCov(obj,measDb)
            res = true;
        end

        function [obj,res] = propState(obj,measDb)
            % A least-squares filter has no time update step. So this
            % function is used to perform some auxiliary operations.
            obj.orbitDb = prepOrbitData(measDb);
            satCount = countSat(measDb,obj.orbitDb);

            if satCount > 3
                obj.x = getApproxState(obj.navState,measDb,obj.orbitDb);
                res = true;
            else
                res = false;
            end
        end

        function [obj,res] = propCov(obj,measDb)
            res = true;
        end

        function [obj,res] = measUpdate(obj,measDb)
            % choose number of iterations, shall be large for the first fix
            if obj.navState.valid
                itCount = 1;
            else
                itCount = 8;
            end

            filterFailed = false;
            obj.dx = zeros(obj.errorStateLen,1);

            % several iterations of the least-squares method
            for itNum=1:1:itCount
                % compute auxiliary data, i. e. LOS vectors, etc.
                auxSatDataDB = repmat(AuxSatData,1,ConfGnssEng.MAX_SV_NUM);

                tmpState = NavState;
                tmpState.POS_x = obj.x(1) + obj.dx(1);
                tmpState.POS_y = obj.x(2) + obj.dx(2);
                tmpState.POS_z = obj.x(3) + obj.dx(3);
                tmpState.CB = obj.x(4) + obj.dx(4);
                tmpState.v_x = obj.x(5) + obj.dx(5);
                tmpState.v_y = obj.x(6) + obj.dx(6);
                tmpState.v_z = obj.x(7) + obj.dx(7);
                tmpState.CD = obj.x(8) + obj.dx(8);
                tmpState.valid = true;

                for i=1:1:ConfGnssEng.MAX_SV_NUM
                    if obj.orbitDb.svOrbitData(i).valid
                        auxSatDataDB(i) = calcAuxSatData(obj.orbitDb.svOrbitData(i),tmpState);
                    end
                end

                % prepare observations
                obsDB = prepMeas(measDb,obj.orbitDb,auxSatDataDB,tmpState); 

                if obsDB.obsCount < 4
                    filterFailed = true;
                    break;
                end

                % prepare variables for least-squares method
                resVec = zeros(obsDB.obsCount,1);
                H = zeros(obsDB.obsCount,8);
                nextObs = 1;

                % fill in H matrix and residual (innovation) vector
                for i=1:1:obsDB.obsCount
                    if obsDB.obs(i).type == ObsType.PR && obsDB.obs(i).gnssId == GnssId.GPS
                        slotNum = getBroadcastDBslotNum(obsDB.obs(i).gnssId, obsDB.obs(i).svId);
                        resVec(nextObs) = obsDB.obs(i).val - auxSatDataDB(slotNum).estRange;
                        H(nextObs,1) = - auxSatDataDB(slotNum).los_e(1);
                        H(nextObs,2) = - auxSatDataDB(slotNum).los_e(2);
                        H(nextObs,3) = - auxSatDataDB(slotNum).los_e(3);
                        H(nextObs,4) = 1;
                        nextObs = nextObs + 1;
                    elseif obsDB.obs(i).type == ObsType.DO && obsDB.obs(i).gnssId == GnssId.GPS
                        slotNum = getBroadcastDBslotNum(obsDB.obs(i).gnssId, obsDB.obs(i).svId);
                        resVec(nextObs) = obsDB.obs(i).val - auxSatDataDB(slotNum).estRangeRate;
                        H(nextObs,5) = - auxSatDataDB(slotNum).los_e(1);
                        H(nextObs,6) = - auxSatDataDB(slotNum).los_e(2);
                        H(nextObs,7) = - auxSatDataDB(slotNum).los_e(3);
                        H(nextObs,8) = 1;
                        nextObs = nextObs + 1;
                    end
                end

                % solve least-squares problem using Kalman filter
                obj.P = diag(repmat(1e12, 1, obj.errorStateLen));
                ddx = zeros(obj.errorStateLen,1);

                for i=1:1:obsDB.obsCount
                    s = H(i,:) * obj.P * H(i,:)' + obsDB.obs(i).var; % s is scalar, s = HPH'+R
                    K = obj.P * H(i,:)' / s; % PH'(HPH'+R)^-1
                    ddx = ddx + K * (resVec(i) - H(i,:) * ddx); % x=x+K(z-Hx)
                    I = eye(obj.errorStateLen);
                    obj.P = (I - K * H(i,:)) * obj.P * (I - K * H(i,:))' + K * obsDB.obs(i).var * K'; % P=(I-KH)P(I-KH)'+KRK'
                end

                obj.dx = obj.dx + ddx;
            end

            if ~filterFailed
                res = true;
            else
                res = false;
            end
        end

        function [obj,res] = correctState(obj)
            obj.x = obj.x + obj.dx;
            obj.navState.POS_x = obj.x(1);
            obj.navState.POS_y = obj.x(2);
            obj.navState.POS_z = obj.x(3);
            obj.navState.CB = obj.x(4);
            obj.navState.v_x = obj.x(5);
            obj.navState.v_y = obj.x(6);
            obj.navState.v_z = obj.x(7);
            obj.navState.CD = obj.x(8);
            obj.navState.valid = true;
            res = true;
        end
    end
end

