function [x_out, res, ttagNew] = propInsGnssLooseState(x_in,sMap,measDb)
    res = true;
    x_out = x_in;
    ttagNew = uint64(0);

    % We need to propagate from previous gyro measurement to the latest
    [gyroDataLast,status] = measDb.gyroBuf.getLastData();
    indPrev = measDb.gyroBuf.decIndex(measDb.gyroBuf.getLastInd());
    if ~status || indPrev == 0
        status = false;
    end
    if status
        gyroDataPrev = measDb.gyroBuf.getData(indPrev);
    end
    if status
        if ~gyroDataPrev.valid || ~gyroDataLast.valid
            status = false;
        end
    end
    if status
        % Get accelerometer data at desired times.
        ttag1 = gyroDataPrev.ttag;
        ttag2 = gyroDataLast.ttag;
        % try to interpolate accelerometer data
        [accelData1,status1] = lib_getAccelDataAt(ttag1,measDb.accelBuf);
        [accelData2,status2] = lib_getAccelDataAt(ttag2,measDb.accelBuf);
        if ~status1
            % We could not interpolate, seems there is no data for given time
            % interval in accelerometer buffers,try to approximate.
            indClosest = measDb.accelBuf.getClosestInd(ttag1);
            if indClosest > 0
                accelData1 = measDb.accelBuf.getData(indClosest);
                dTtag = lib_ttagDiffUint64(ttag1,accelData1.ttag);
                if abs(dTtag) > SfConst.ImuTimeout
                    status = false;
                end
            else
                status = false;
            end
        end
        if ~status2
            % We could not interpolate, seems there is no data for given time
            % interval in accelerometer buffers,try to approximate.
            indClosest = measDb.accelBuf.getClosestInd(ttag2);
            if indClosest > 0
                accelData2 = measDb.accelBuf.getData(indClosest);
                dTtag = lib_ttagDiffUint64(ttag2,accelData2.ttag);
                if abs(dTtag) > SfConst.ImuTimeout
                    status = false;
                end
            else
                status = false;
            end
        end
    end
    if status
        % We have data to do state prediction
        x_out = propInsGnssLooseRkTwoDt(x_in, sMap, gyroDataPrev.omega_is, gyroDataLast.omega_is,...
            accelData1.f_b, accelData2.f_b, 1e-6 * lib_ttagDiffUint64(ttag2, ttag1));
        x_out(sMap.Q_ES) = x_out(sMap.Q_ES) / sqrt(x_out(sMap.Q_ES)' * x_out(sMap.Q_ES)); % Quaternion normalization
        ttagNew = ttag2;
    end
    if ~status
        res = false;
    end
end

