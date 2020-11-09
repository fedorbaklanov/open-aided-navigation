classdef InsGnssFilterLoose < NavFilter
    properties (SetAccess='private', GetAccess='public')
        x  % total state vector
        dx % error state vector
        P  % error covariance matrix
    end
    properties (Constant, Access='private')
        stateMap = StateMapInsGnssLoose
        errorStateMap = ErrorStateMapInsGnssLoose
        params = ParamsInsGnssFilterLoose
        maxObsCnt = 20
    end
    properties (Access='private')
        filTtagPrev;
        lastUsedGnssTtag;
        obsDb;
        H;
    end

    methods
        function [obj] = InsGnssFilterLoose()
            obj.obsDb = ObsDb(obj.maxObsCnt);
            obj.H = zeros(obj.maxObsCnt, obj.errorStateMap.LEN);
            obj = reset(obj);
        end

        function [obj] = reset(obj)
            obj.x = zeros(obj.stateMap.LEN,1);
            obj.dx = zeros(obj.errorStateMap.LEN,1);
            obj.P = eye(obj.errorStateMap.LEN,obj.errorStateMap.LEN);
            obj.mode = FilterMode.IDLE;
            obj.filTtag = uint64(0);
            obj.lastUsedGnssTtag = uint64(0);
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
                    % check if there are enough measurements to initialize
                    canInit = checkInit(obj,measDb);
                    if canInit
                        obj.mode = FilterMode.INIT;
                    end
                    res = true;
                case FilterMode.INIT
                    % check if there are enough measurements to initialize
                    canInit = checkInit(obj,measDb);
                    if ~canInit
                        obj.mode = FilterMode.IDLE;
                    end
                    res = true;
                case FilterMode.RUNNING
                    % check if we are able to do time update
                    canProp = checkProp(obj,measDb);
                    if ~canProp
                        res = false;
                    else
                        res = true;
                    end
                otherwise
                    res = false;
            end
        end

        function [obj,res] = initState(obj,measDb)
            res = false;
            conf = obj.params;
            sMap = obj.stateMap;
            [lastGnssData,status] = measDb.gnssBuf.getLastData();
            if status
                [ind,status] = measDb.gnssBuf.getLastIndLe(lastGnssData.ttag - uint64(conf.MIN_VEL_INIT_INTERVAL * 1e6));
            end
            if status
                gnssDataOld = measDb.gnssBuf.getData(ind);
                dTtag = lib_ttagDiffUint64(lastGnssData.ttag,gnssDataOld.ttag);
                x_e_old = lib_llhToEcef(gnssDataOld.lat,gnssDataOld.lon,gnssDataOld.height,Wgs84);
                x_e = lib_llhToEcef(lastGnssData.lat,lastGnssData.lon,lastGnssData.height,Wgs84);
                C_ne = lib_dcmEcefToNed(lastGnssData.lat,lastGnssData.lon);
                dx_n = C_ne * (x_e - x_e_old);
                if norm(dx_n(1:2)) < conf.MIN_DPOS_VEL_INIT ||...
                        dTtag < 1e6 * conf.MIN_VEL_INIT_INTERVAL ||...
                        dTtag > 1e6 * conf.MAX_VEL_INIT_INTERVAL
                    status = false;
                end
            end
            if status
                [lastAccelData,status] = measDb.accelBuf.getLastData();
            end
            if status
                [lastGyroData,status] = measDb.gyroBuf.getLastData();
            end
            if status
                if lastAccelData.valid
                    norm_f_b = norm(lastAccelData.f_b);
                    if abs(norm_f_b - 9.81) < conf.ATT_INIT_ACCEL_THRES
                        % Initialize orientation
                        phi = atan2(-lastAccelData.f_b(2), -lastAccelData.f_b(3));
                        theta = asin(lastAccelData.f_b(1) / norm_f_b);
                        psi = atan2(dx_n(2),dx_n(1)) + obj.params.YAW_IMU2CAR;
                        q_ns = lib_eulerToQuat(phi, theta, psi); % From s- to n-frame
                        q_en = lib_quatEcefToNed(lastGnssData.lat, lastGnssData.lon); % From e- to n-frame
                        q_en = [q_en(1); -q_en(2:4)]; % From n- to e-frame
                        obj.x(sMap.Q_ES) = lib_quatMult(q_en, q_ns); % From s- to e-frame
                        % Initialize position
                        obj.x(sMap.POS_E) = x_e;
                        % Initialize velocity
                        obj.x(sMap.V_E) = (x_e - x_e_old) / dTtag;
                        % Set initial scale factors
                        obj.x(sMap.S_F) = ones(3,1);
                        obj.x(sMap.S_W) = ones(3,1);
                        % Set initial rotation from IMU to car
                        obj.x(sMap.Q_CS) = lib_eulerToQuat(obj.params.ROLL_IMU2CAR,...
                            obj.params.PITCH_IMU2CAR, obj.params.YAW_IMU2CAR);
                        % Other states are initialzed with zeros.
                        % We will use gyro events to trigger epochs.
                        obj.filTtag = lastGyroData.ttag;
                        res = true;
                    end
                end
            end
        end

        function [obj,res] = initCov(obj,measDb)
            res = false;
            esMap = obj.errorStateMap;
            [lastGnssData,status] = measDb.gnssBuf.getLastData();
            if status
                C_ne = lib_dcmEcefToNed(lastGnssData.lat,lastGnssData.lon);
                % Set up initial position covariance
                tmpCov = 9 * diag([lastGnssData.hAcc^2, lastGnssData.hAcc^2, (3 * lastGnssData.hAcc)^2]);
                obj.P(esMap.POS_E,esMap.POS_E) = C_ne' * tmpCov * C_ne;
                % Set up initial velocity covariance
                tmpCov = diag([(10)^2, (10)^2, (1)^2]);
                obj.P(esMap.V_E,esMap.V_E) = C_ne' * tmpCov * C_ne;
                % Set up initial orientation covariance
                tmpCov = diag([(0.1)^2, (0.1)^2, (0.6)^2]);
                obj.P(esMap.PSI_EE,esMap.PSI_EE) = C_ne' * tmpCov * C_ne;
                % Set up initial variances for accelerometer offsets
                obj.P(esMap.B_F,esMap.B_F) = diag([(0.2)^2, (0.2)^2, (0.2)^2]);
                % Set up initial variances for gyroscope offsets
                obj.P(esMap.B_W,esMap.B_W) = diag([(0.005)^2, (0.005)^2, (0.005)^2]);
                % Set up initial scale factor variances
                obj.P(esMap.S_F,esMap.S_F) = diag(repmat((5e-3)^2,1,3));
                obj.P(esMap.S_W,esMap.S_W) = diag(repmat((5e-3)^2,1,3));
                % Set up initial mounting alignment covariance
                obj.P(esMap.PSI_CC,esMap.PSI_CC) = diag(repmat((0.17)^2,1,3));
                res = true;
            end
        end

        function [obj,res] = propState(obj,measDb)
            [x_tmp, res, ttagNew] = propInsGnssLooseState(obj.x,obj.stateMap,measDb);
            if res
                obj.x = x_tmp;
                obj.filTtagPrev = obj.filTtag;
                obj.filTtag = ttagNew;
            end
        end

        function [obj,res] = propCov(obj,measDb)
            [Phi,res] = insGnssLooseTransMat(obj.x,obj.stateMap,obj.errorStateMap,...
                obj.filTtagPrev,obj.filTtag,measDb);
            if res
                [Q,res] = insGnssLooseSysNoiseMat(obj.x,obj.stateMap,obj.errorStateMap,...
                    obj.filTtagPrev,obj.filTtag);
            end
            if res
                obj.P = Phi * obj.P * Phi' + Q;
            end
        end

        function [obj,res] = measUpdate(obj,measDb)
            obj.obsDb = obj.obsDb.reset();
            obj = obj.prepObs(measDb);
            [obj.dx,obj.P] = lib_kfUpdateJoseph(obj.P,obj.obsDb,obj.H);
            res = true;
        end

        function [obj,res] = correctState(obj)
            sMap = obj.stateMap;
            esMap = obj.errorStateMap;
            % correct position and velocity states
            obj.x(sMap.POS_E) = obj.x(sMap.POS_E) + obj.dx(esMap.POS_E);
            obj.x(sMap.V_E) = obj.x(sMap.V_E) + obj.dx(esMap.V_E);
            % correct IMU errors and feature coordinates
            obj.x(sMap.B_F) = obj.x(sMap.B_F) + obj.dx(esMap.B_F);
            obj.x(sMap.S_F) = obj.x(sMap.S_F) + obj.dx(esMap.S_F);
            obj.x(sMap.B_W) = obj.x(sMap.B_W) + obj.dx(esMap.B_W);
            obj.x(sMap.S_W) = obj.x(sMap.S_W) + obj.dx(esMap.S_W);
            % correct orientation quaternion
            psi_ee_tilde = obj.dx(esMap.PSI_EE);
            q_tmp = lib_eulerToQuat(psi_ee_tilde(1),psi_ee_tilde(2),psi_ee_tilde(3));
            q_tmp = lib_quatMult(q_tmp,obj.x(sMap.Q_ES));
            obj.x(sMap.Q_ES) = q_tmp / sqrt(q_tmp' * q_tmp);
            % correct mounting alignment
            psi_cc_tilde = obj.dx(esMap.PSI_CC);
            q_tmp = lib_eulerToQuat(psi_cc_tilde(1),psi_cc_tilde(2),psi_cc_tilde(3));
            q_tmp = lib_quatMult(q_tmp,obj.x(sMap.Q_CS));
            obj.x(sMap.Q_CS) = q_tmp / sqrt(q_tmp' * q_tmp);
            res = true;
        end
    end

    methods (Access='private')
        function [canInit] = checkInit(~,measDb)
            [gyroData,canInit] = measDb.gyroBuf.getLastData();
            if canInit
                [accelData,canInit] = measDb.accelBuf.getLastData();
            end
            if canInit
                [gnssData,canInit] = measDb.gnssBuf.getLastData();
            end
            if canInit
                dTtagAccelGyro = lib_ttagDiffUint64(accelData.ttag,gyroData.ttag);
                dTtagAccelGnss = lib_ttagDiffUint64(accelData.ttag,gnssData.ttag);
                dTtagGyroGnss = lib_ttagDiffUint64(gyroData.ttag,gnssData.ttag);

                if abs(dTtagAccelGyro) > SfConst.ImuTimeout ||...
                   abs(dTtagAccelGnss) > SfConst.ImuTimeout ||...
                   abs(dTtagGyroGnss) > SfConst.ImuTimeout
                    canInit = false;
                end
            end
        end

        function [canProp] = checkProp(obj,measDb)
            [gyroData,canProp] = measDb.gyroBuf.getLastData();
            if canProp
                [indGyroPrevEpoch,canProp] = measDb.gyroBuf.getLastIndLe(obj.filTtag);
            end
            if canProp
                indShift = 0;
                lastInd = measDb.gyroBuf.getLastInd();
                if indGyroPrevEpoch > lastInd
                    indShift = measDb.gyroBuf.capacity;
                end
                if (lastInd + indShift - indGyroPrevEpoch) ~= 1
                    % We would like to propagate from one gyro ttag to the
                    % next one.
                    canProp = false;
                end
            end
            if canProp
                % Check gyro timeout
                gyroDataPrevEpoch = measDb.gyroBuf.getData(indGyroPrevEpoch);
                dTtag = lib_ttagDiffUint64(gyroData.ttag,gyroDataPrevEpoch.ttag);
                if dTtag <= 0 || dTtag > SfConst.ImuTimeout
                    canProp = false;
                end
            end
            if canProp
                % Check if we will be able to interpolate or approximate
                % accelerometer data at gyroData.ttag and at
                % gyroDataPrevEpoch.ttag.
                [indAccel_1,statusAccel_1] = measDb.accelBuf.getLastIndLe(gyroDataPrevEpoch.ttag);
                [indAccel_2,statusAccel_2] = measDb.accelBuf.getLastIndLe(gyroData.ttag);
                if ~statusAccel_1 || ~statusAccel_2
                    canProp = false;
                end
                if canProp
                    accelData1 = measDb.accelBuf.getData(indAccel_1);
                    accelData2 = measDb.accelBuf.getData(indAccel_2);
                    if ~accelData1.valid || ~accelData2.valid
                        canProp = false;
                    end
                    if canProp
                        % Check that we can interpolate or extrapolate
                        % accelerometer data at gyroData.ttag.
                        dTtag = lib_ttagDiffUint64(gyroData.ttag,accelData2.ttag);
                        if dTtag > SfConst.ImuTimeout
                            canProp = false;
                        end
                    end
                    if canProp
                        % Check that there is not timeout between
                        % accelData1 and accelData2.
                        ind2 = indAccel_2;
                        while ind2 > indAccel_1
                            ind1 = measDb.accelBuf.decIndex(ind2);
                            ttag1 = measDb.accelBuf.ttags(ind1);
                            ttag2 = measDb.accelBuf.ttags(ind2);
                            if lib_ttagDiffUint64(ttag2,ttag1) >= SfConst.ImuTimeout
                                canProp = false;
                                break;
                            end
                            ind2 = ind1;
                        end
                    end
                end
            end
        end

        function [obj] = prepObs(obj,measDb)
            obj.H = zeros(size(obj.H));
            [obj] = obj.prepGnssUpdate(measDb);
            if obj.params.USE_NHC
                [obj] = obj.prepNhcUpdate(measDb);
            end
        end

        function [obj] = prepGnssUpdate(obj,measDb)
            sMap = obj.stateMap;
            esMap = obj.errorStateMap;

            [indGnssData,status] = measDb.gnssBuf.getLastIndLe(obj.filTtag);
            if status
                gnssData = measDb.gnssBuf.getData(indGnssData);
                dTtag = lib_ttagDiffUint64(obj.filTtag, gnssData.ttag);

                % Check that the GNSS measurement is not too outdated
                if dTtag >= 0 && dTtag < SfConst.ImuTimeout / 2 &&...
                        gnssData.ttag ~= obj.lastUsedGnssTtag
                    % Convert measured llh to ecef coordinates
                    x_e_meas = lib_llhToEcef(gnssData.lat,gnssData.lon,gnssData.height,Wgs84);

                    % Set up measurement covariance. Many smartphones do
                    % not provide vertical accuracy, so here this parameter
                    % is "approximated" using horizontal accuracy.
                    R_n = diag([gnssData.hAcc^2; gnssData.hAcc^2; (2.5 * gnssData.hAcc)^2]);
                    [lat,lon,~] = lib_ecefToLlh(obj.x(sMap.POS_E),Wgs84);
                    C_en = lib_dcmEcefToNed(lat,lon);
                    R_e = C_en * R_n * C_en';

                    % Decorrelate measurement vector. This is needed
                    % because we would like to do KF update scalar by
                    % scalar in order to avoid matrix inversion. This is
                    % only possible when R matrix is a diagonal matrix. The
                    % transformation below will results into R matrix being
                    % an identity matrix.
                    U = chol(R_e);
                    T = (U')^-1;
                    x_e_meas = T * x_e_meas;
                    x_e_est = T * obj.x(sMap.POS_E);

                    % Get delta time between measurements to scale
                    % observation variance. This ensures that output
                    % covariance is independent of update frequency.
                    dTtag = 1e-6 * lib_ttagDiffUint64(obj.filTtag,obj.lastUsedGnssTtag);
                    if dTtag == 0 || dTtag >= 1
                        dTtag = 1;
                    end

                    % Mark measurement as used
                    obj.lastUsedGnssTtag = gnssData.ttag;

                    % Derive measurement matrix
                    H_tmp = zeros(3,esMap.LEN);
                    H_tmp(1:3,esMap.POS_E) = eye(3);
                    H_tmp = T * H_tmp;

                    % Do chi-square test to detect outliers
                    res = x_e_meas - x_e_est;
                    needToReject = lib_testChi2(res, obj.P, H_tmp, eye(3));

                    if ~needToReject
                        obsTypes = [ObsType.POS_E_X, ObsType.POS_E_Y, ObsType.POS_E_Z];
                        % Add measurements to observation database
                        for i=1:1:3
                            [obj.obsDb,res] = obj.obsDb.add(obsTypes(i), x_e_meas(i), x_e_est(i), 1 / dTtag);
                            if res
                                obj.H(obj.obsDb.obsCount,:) = H_tmp(i,:);
                            end
                        end
                    end
                end
            end
        end

        function [obj] = prepNhcUpdate(obj,measDb)
            sMap = obj.stateMap;
            esMap = obj.errorStateMap;
            conf = obj.params;

            % Get latest IMU data and compensate it.
            gyroData = measDb.gyroBuf.getLastData();
            accelData = measDb.accelBuf.getLastData();
            b_omega = obj.x(sMap.B_W);
            s_omega = obj.x(sMap.S_W);
            b_f = obj.x(sMap.B_F);
            s_f = obj.x(sMap.S_F);
            omega_is = (s_omega .* gyroData.omega_is) + b_omega;
            f_s = (s_f .* accelData.f_b) + b_f;

            % Non-holonomic constraints, are not valid in dynamic
            % situations. This is especially critical for the lateral
            % velocity vector component.
            if norm(omega_is) < conf.NHC_RATE_THRES &&...
                    abs(norm(f_s) - 9.81) < conf.NHC_ACCEL_THRES
                % Get delta time between measurements to scale
                % observation variance. This ensures that output
                % covariance is independent of update frequency.
                dTtag = 1 / double(conf.GYRO_FREQ);
                if dTtag >= 1
                    dTtag = 1;
                end

                % Priject velocity to car frame, derive measurement
                % matrix, and set up measurement covariance.
                C_ce = lib_quatToDcm(obj.x(sMap.Q_CS)) * (lib_quatToDcm(obj.x(sMap.Q_ES)))';
                v_c = C_ce * obj.x(sMap.V_E);

                H_tmp = zeros(3,esMap.LEN);
                H_tmp(1:3,esMap.V_E) = C_ce;
                H_tmp(1:3,esMap.PSI_EE) = C_ce * lib_skewMat(obj.x(sMap.V_E));
                H_tmp(1:3,esMap.PSI_CC) = lib_skewMat(-v_c);

                meas_var = [(0.1)^2, (0.05)^2];

                % Do chi-square test to detect outliers
                needToRejectVelLat = lib_testChi2(-v_c(2), obj.P, H_tmp(2,:), meas_var(1));
                needToRejectVelVer = lib_testChi2(-v_c(3), obj.P, H_tmp(3,:), meas_var(2));

                if ~needToRejectVelLat
                    % Add measurements to observation database
                    [obj.obsDb,res] = obj.obsDb.add(ObsType.VEL_C_Y, 0, v_c(2), meas_var(1) / dTtag);
                    if res
                        obj.H(obj.obsDb.obsCount,:) = H_tmp(2,:);
                    end
                end
                if ~needToRejectVelVer
                    [obj.obsDb,res] = obj.obsDb.add(ObsType.VEL_C_Z, 0, v_c(3), meas_var(2) / dTtag);
                    if res
                        obj.H(obj.obsDb.obsCount,:) = H_tmp(3,:);
                    end
                end
            end
        end
    end
end

