function [Qd,status] = insGnssLooseSysNoiseMat(x,sMap,esMap,ttagPrev,ttagNew)
    status = true;
    Qd = zeros(esMap.LEN,esMap.LEN);
    dt = 1e-6 * double(lib_ttagDiffUint64(ttagNew,ttagPrev));
    if dt == 0
        status = false;
    end

    if status
        G = zeros(esMap.LEN,21);
        C_es = lib_quatToDcm(x(sMap.Q_ES));

        G(esMap.V_E,1:3) = C_es;
        G(esMap.PSI_EE,4:6) = C_es;
        G(esMap.B_F,7:9) = eye(3);
        G(esMap.B_W,10:12) = eye(3);
        G(esMap.S_F,13:15) = eye(3);
        G(esMap.S_W,16:18) = eye(3);
        G(esMap.PSI_CC,19:21) = eye(3);

        accelNoiseVar = [(3e-2)^2, (3e-2)^2, (3e-2)^2];
        gyroNoiseVar = [(5e-3)^2, (5e-3)^2, (5e-3)^2];
        accelBiasNoiseVar = [1e-10, 1e-10, 1e-10];
        gyroBiasNoiseVar = [1e-12, 1e-12, 1e-12];
        scaleFactorNoiseVar = repmat(1e-10,1,6);
        alignmentNoiseVar = [1e-8, 1e-8, 1e-8];

        Q = diag([accelNoiseVar, gyroNoiseVar, accelBiasNoiseVar,...
            gyroBiasNoiseVar, scaleFactorNoiseVar, alignmentNoiseVar]);
        Qd = G * Q * G' * dt;
    end
end

