function [Phi,status] = insGnssLooseTransMat(x,sMap,esMap,ttagPrev,ttagNew,measDb)
    Phi = zeros(esMap.LEN,esMap.LEN);
    status = true;

    [accelData,status1] = lib_getAccelDataAt(ttagNew,measDb.accelBuf);
    if ~status1
        % We could not interpolate, let us try to approximate
        indClosest = measDb.accelBuf.getClosestInd(ttagNew);
        if indClosest > 0
            accelData = measDb.accelBuf.getData(indClosest);
            dTtag = lib_ttagDiffUint64(ttagNew,accelData.ttag);
            if abs(dTtag) > SfConst.ImuTimeout
                status = false;
            end
        else
            status = false;
        end
    end
    [gyroData,status1] = measDb.gyroBuf.getLastData();
    if ~status1
        status = false;
    end
    if status
        C_es = lib_quatToDcm(x(sMap.Q_ES));
        f_s = (x(sMap.S_F) .* accelData.f_b) + x(sMap.B_F); % Compensate accelerometer offset
        % Rows for position error
        Phi(esMap.POS_E,esMap.V_E) = eye(3);
        % Rows for velocity error
        Phi(esMap.V_E,esMap.V_E) = lib_skewMat([0; 0; -2 * Wgs84.omega_ie]);
        Phi(esMap.V_E,esMap.PSI_EE) = lib_skewMat(C_es * (-f_s));
        Phi(esMap.V_E,esMap.B_F) = C_es;
        Phi(esMap.V_E,esMap.S_F) = C_es * diag(accelData.f_b); % We must use uncompensated force here
        % Rows for orientation error
        Phi(esMap.PSI_EE,esMap.PSI_EE) = lib_skewMat([0; 0; -Wgs84.omega_ie]);
        Phi(esMap.PSI_EE,esMap.B_W) = C_es;
        Phi(esMap.PSI_EE,esMap.S_W) = C_es * diag(gyroData.omega_is); % We must use uncompensated rate here

        dTtag = lib_ttagDiffUint64(ttagNew,ttagPrev);
        Phi = eye(esMap.LEN) + (1e-6 * double(dTtag)) * Phi;
    end
end

