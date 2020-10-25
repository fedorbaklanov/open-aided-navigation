function [svOk] = checkGpsSv(gpsBcData)
    if (gpsBcData.alertFlag == 0 &&...
        gpsBcData.svHealth == 0 &&...
        gpsBcData.svAcc < 15)
        svOk = true;
    else
        svOk = false;
    end
end

