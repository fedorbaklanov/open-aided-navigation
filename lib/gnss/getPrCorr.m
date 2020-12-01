function [prCorr,ionoApplied] = getPrCorr(svId,orbitData,auxSatData,navState)
    global sbasInfo;
    prCorr = 0;
    ionoApplied = false;
    constGps = getGpsConstants();
    CB = navState.CB;


    satClockCorr = constGps.c * orbitData.dt_sv;
    sagnacPrCorr = deriveSagnacPrCorr(navState,orbitData);
    ionoCorr = constGps.c * deriveKlobucharIonoCorr(navState,orbitData,auxSatData);

    if ionoCorr > 0
        ionoApplied = true;
    end

    prCorr = prCorr - CB + satClockCorr - sagnacPrCorr - ionoCorr;
end

