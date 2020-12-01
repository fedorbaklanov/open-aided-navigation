classdef GnssPvtFilter < NavFilter
    properties (SetAccess='private', GetAccess='public')
        x;  % total state vector
        dx; % error state vector
        P;  % error covariance matrix
        orbitDb; % auxiliary orbit data
    end

    properties (Access='private',Constant)
        stateLen = 8;
        errorStateLen = 8;
    end

    properties (Access='private')
        obsDb;
        H;
        dTtagEpoch = uint64(0);
        lastFixTtag = uint64(0);
        stateMap = StateMapGnssPvt;
        errorStateMap = ErrorStateMapGnssPvt;
    end

    methods
        function [obj] = GnssPvtFilter()
            obj.obsDb = ObsDb(3 * ConfGnssEng.MAX_SIGMEAS_NUM);
            obj.H = zeros(3 * ConfGnssEng.MAX_SIGMEAS_NUM, 8);
            obj = reset(obj);
        end

        function [obj] = reset(obj)
            obj.x = zeros(obj.stateMap.LEN,1);
            obj.dx = zeros(obj.errorStateMap.LEN,1);
            obj.P = eye(obj.errorStateMap.LEN,obj.errorStateMap.LEN);
            obj.mode = FilterMode.IDLE;
            obj.filTtag = uint64(0);
            obj.dTtagEpoch = uint64(0);
            obj.lastFixTtag = uint64(0);
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
            switch obj.mode
                case FilterMode.IDLE
                    if measDb.navState.valid
                        % We have some initial position information to
                        % initialize. It comes from the LSQ filter.
                        obj.mode = FilterMode.INIT;
                    end
                    res = true;
                case FilterMode.INIT
                    if ~measDb.navState.valid
                        % We will not be able to initialize, go to IDLE
                        % mode.
                        obj.mode = FilterMode.IDLE;
                    end
                    res = true;
                case FilterMode.RUNNING
                    % Navigation calculations are triggered by raw GNSS
                    % measurements that must come cyclically. No
                    % measurements -- do nothing and reset, because we even
                    % do not have new valid timestamp to do state
                    % propagation.
                    if measDb.valid && measDb.ttagRcvValid
                        newTtag = uint64(1e-3 * measDb.ttagRcv);
                        dTtag = lib_ttagDiffUint64(newTtag,obj.filTtag);
                        if dTtag > 0 && dTtag < 3e6
                            % Check that time difference between epochs is
                            % not to large.
                            res = true;
                        else
                            res = false;
                        end
                        if res
                            % Check that position accuracy is still ok,
                            % otherwise reset and start from no fix.
                            if obj.P(1,1) > (500)^2 ||...
                                    obj.P(2,2) > (500)^2 ||...
                                    obj.P(3,3) > (500)^2
                                res = false;
                            end
                        end
                    else
                        res = false;
                    end
                otherwise
                    res = false;
            end
        end

        function [obj,res] = initState(obj,measDb)
            % This function simpy takes approximate position and velocity
            % derived by the LSQ filter and initializes the state vector
            % accordingly.
            sMap = obj.stateMap;
            obj.x(sMap.POS_EX) = measDb.navState.POS_x;
            obj.x(sMap.POS_EY) = measDb.navState.POS_y;
            obj.x(sMap.POS_EZ) = measDb.navState.POS_z;
            obj.x(sMap.CB) = measDb.navState.CB;
            obj.x(sMap.V_EX) = measDb.navState.v_x;
            obj.x(sMap.V_EY) = measDb.navState.v_y;
            obj.x(sMap.V_EZ) = measDb.navState.v_z;
            obj.x(sMap.CD) = measDb.navState.CD;
            obj.filTtag = uint64(1e6 * measDb.navState.gpsTow);
            obj.lastFixTtag = obj.filTtag;
            res = true;
        end

        function [obj,res] = initCov(obj,measDb)
            esMap = obj.errorStateMap;
            % Diagonal elements of the covariance matrix are initialized
            % here. For simplicity, estimated elements of the covariance
            % matrix are not inherited from the LSQ filter. However, one
            % can think of introducing such an improvement. Values used
            % here are simply some "large enough" numbers.
            obj.P(esMap.POS_EX,esMap.POS_EX) = (100)^2;
            obj.P(esMap.POS_EY,esMap.POS_EY) = (100)^2;
            obj.P(esMap.POS_EZ,esMap.POS_EZ) = (100)^2;
            obj.P(esMap.CB,esMap.CB) = (10000)^2;
            obj.P(esMap.V_EX,esMap.V_EX) = (20)^2;
            obj.P(esMap.V_EY,esMap.V_EY) = (20)^2;
            obj.P(esMap.V_EZ,esMap.V_EZ) = (20)^2;
            obj.P(esMap.CD,esMap.CD) = (1000)^2;
            res = true;
        end

        function [obj,res] = propState(obj,measDb)
            newTtag = uint64(1e-3 * measDb.ttagRcv);
            dTtag = lib_ttagDiffUint64(newTtag,obj.lastFixTtag);
            if dTtag < 0 || dTtag > 5e6
                % We cannot propagate for too long, because our state
                % (motion) model is very inaccurate.
                res = false;
            else
                % Do simple state propagation: position increment is an
                % integral of velocity, increment of a clock bias is an
                % integral of the clock drift.
                obj.dTtagEpoch = lib_ttagDiffUint64(newTtag,obj.filTtag);
                sMap = obj.stateMap;
                obj.x(sMap.POS_E) = obj.x(sMap.POS_E) + (1e-6 * double(obj.dTtagEpoch)) * obj.x(sMap.V_E); % Predict position
                obj.x(sMap.CB) = obj.x(sMap.CB) + (1e-6 * double(obj.dTtagEpoch)) * obj.x(sMap.CD); % Predict clock bias
                obj.filTtag = newTtag;
                res = true;
            end
        end

        function [obj,res] = propCov(obj,measDb)
            % This function propagates covariance matrix. Clock states need
            % to be reset, if the receiver has realigned its clock at this
            % epoch.
            Phi = gnssPvtTransMat(obj.dTtagEpoch,obj.errorStateMap);
            Q = gnssPvtSysNoiseMat(obj.x,obj.dTtagEpoch,obj.errorStateMap);
            if measDb.ttagRcvReset
                obj.P(sMap.CB,:) = zeros(1,obj.errorStateMap.LEN);
                obj.P(:,sMap.CB) = zeros(obj.errorStateMap.LEN,1);
                obj.P(sMap.CD,:) = zeros(1,obj.errorStateMap.LEN);
                obj.P(:,sMap.CD) = zeros(obj.errorStateMap.LEN,1);
                obj.P(sMap.CB,sMap.CB) = (10000)^2;
                obj.P(sMap.CD,sMap.CD) = (1000)^2;
            end
            obj.P = Phi * obj.P * Phi' + Q; % Covariance propagation itself
            res = true;
        end

        function [obj,res] = measUpdate(obj,measDb)
            obj.obsDb = obj.obsDb.reset(); % Clear observation database in order not to use false residuals from the previous eposh
            obj.orbitDb = prepOrbitData(measDb);
            obj = obj.prepObs(measDb); % Derive residuals and their variances, etc.
            svCount = obj.countSvs(obj.obsDb); % Check how many valid measurement there are
            if svCount > 3
                % Do update only if the system is overdetermined, simply
                % propagate otherwise. It is not mandatory to skip update
                % when the system is not overdetermined.
                [obj.dx,obj.P] = lib_kfUpdateJoseph(obj.P,obj.obsDb,obj.H);
                obj.lastFixTtag = obj.filTtag;
            end
            res = true;
        end

        function [obj,res] = correctState(obj)
            % Compensate an error of the state vector using the estimated
            % error from this epoch.
            obj.x = obj.x + obj.dx;
            res = true;
        end
    end

    methods (Access='private')
        function [obj] = prepObs(obj,measDb)
            obj.H = zeros(size(obj.H));
            sMap = obj.stateMap;
            esMap = obj.errorStateMap;
            auxSatDataDB = repmat(AuxSatData,1,ConfGnssEng.MAX_SV_NUM);

            tmpState = NavState;
            tmpState.POS_x = obj.x(sMap.POS_EX);
            tmpState.POS_y = obj.x(sMap.POS_EY);
            tmpState.POS_z = obj.x(sMap.POS_EZ);
            tmpState.CB = obj.x(sMap.CB);
            tmpState.v_x = obj.x(sMap.V_EX);
            tmpState.v_y = obj.x(sMap.V_EY);
            tmpState.v_z = obj.x(sMap.V_EZ);
            tmpState.CD = obj.x(sMap.CD);
            tmpState.valid = true;

            % Derive auxiliary data, such as line-of-sight vectors,
            % elevation angles, etc.
            for i=1:1:ConfGnssEng.MAX_SV_NUM
                if obj.orbitDb.svOrbitData(i).valid
                    auxSatDataDB(i) = calcAuxSatData(obj.orbitDb.svOrbitData(i),tmpState);
                end
            end

            % prepare observations, i. e. do compensation of GNSS
            % measurements, etc.
            gnssObsDB = prepMeas(measDb,obj.orbitDb,auxSatDataDB,tmpState);

            % fill in H matrix and residual (innovation) vector
            for i=1:1:gnssObsDB.obsCount
                if gnssObsDB.obs(i).type == ObsType.PR && gnssObsDB.obs(i).gnssId == GnssId.GPS
                    % Handle pseudorange
                    slotNum = getBroadcastDBslotNum(gnssObsDB.obs(i).gnssId, gnssObsDB.obs(i).svId);
                    [obj.obsDb,res] = obj.obsDb.add(ObsType.PR, gnssObsDB.obs(i).val, auxSatDataDB(slotNum).estRange, gnssObsDB.obs(i).var);
                    if res
                        obj.H(obj.obsDb.obsCount,esMap.POS_EX) = - auxSatDataDB(slotNum).los_e(1);
                        obj.H(obj.obsDb.obsCount,esMap.POS_EY) = - auxSatDataDB(slotNum).los_e(2);
                        obj.H(obj.obsDb.obsCount,esMap.POS_EZ) = - auxSatDataDB(slotNum).los_e(3);
                        obj.H(obj.obsDb.obsCount,esMap.CB) = 1;
                    end
                    if res
                        curInd = obj.obsDb.obsCount;
                        needToReject = lib_testChi2(obj.obsDb.obs(curInd).res, obj.P, obj.H(curInd,:), obj.obsDb.obs(curInd).var);
                        if needToReject
                            obj.obsDb = obj.obsDb.setInvalid(curInd);
                        end
                    end
                elseif gnssObsDB.obs(i).type == ObsType.DO && gnssObsDB.obs(i).gnssId == GnssId.GPS
                    % Handle range rate
                    slotNum = getBroadcastDBslotNum(gnssObsDB.obs(i).gnssId, gnssObsDB.obs(i).svId);
                    [obj.obsDb,res] = obj.obsDb.add(ObsType.DO, gnssObsDB.obs(i).val, auxSatDataDB(slotNum).estRangeRate, gnssObsDB.obs(i).var);
                    if res
                        obj.H(obj.obsDb.obsCount,esMap.V_EX) = - auxSatDataDB(slotNum).los_e(1);
                        obj.H(obj.obsDb.obsCount,esMap.V_EY) = - auxSatDataDB(slotNum).los_e(2);
                        obj.H(obj.obsDb.obsCount,esMap.V_EZ) = - auxSatDataDB(slotNum).los_e(3);
                        obj.H(obj.obsDb.obsCount,esMap.CD) = 1;
                    end
                    if res
                        curInd = obj.obsDb.obsCount;
                        needToReject = lib_testChi2(obj.obsDb.obs(curInd).res, obj.P, obj.H(curInd,:), obj.obsDb.obs(curInd).var);
                        if needToReject
                            obj.obsDb = obj.obsDb.setInvalid(curInd);
                        end
                    end
                end
            end
        end

        function [svCount] = countSvs(~,obsDb)
            svCount = 0;
            for i=1:1:obsDb.obsCount
                if obsDb.obs(i).valid && obsDb.obs(i).type == ObsType.PR
                    svCount = svCount + 1;
                end
            end
        end
    end
end

