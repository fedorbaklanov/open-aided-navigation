function [accelData,status] = lib_getAccelDataAt(ttag,accelBuf)
    accelData = AccelData;
    status = true;
    indFirst = accelBuf.getFirstInd();
    indLast = accelBuf.getLastInd();
    if indLast == 0 || indFirst == 0
        status = false;
    end
    if status
        if accelBuf.ttags(indFirst) > ttag || ttag > accelBuf.ttags(indLast)
            status = false;
        end
    end
    if status
        if accelBuf.ttags(indFirst) == ttag
            accelData = accelBuf.getData(indFirst);
        elseif accelBuf.ttags(indLast) == ttag
            accelData = accelBuf.getData(indLast);
        else
            [indAccel_1,~] = accelBuf.getLastIndLe(ttag);
            indAccel_2 = accelBuf.incIndex(indAccel_1);
            if indAccel_1 > 0 && indAccel_2 > 0
                accelData1 = accelBuf.getData(indAccel_1);
                accelData2 = accelBuf.getData(indAccel_2);
                [f_b,status] = lib_linInterp(accelData1.f_b,accelData2.f_b,...
                                             accelData1.ttag,accelData2.ttag,ttag);
                if status
                    accelData.valid = true;
                    accelData.ttag = ttag;
                    accelData.f_b = f_b;
                end
            else
                status = false;
            end
        end
    end
end

