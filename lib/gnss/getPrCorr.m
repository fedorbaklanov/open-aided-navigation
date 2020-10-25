function [prCorr] = getPrCorr(svId,orbitData,auxSatData,navState)
    global sbasInfo;
    prCorr = 0;
    constGps = getGpsConstants();
    CB = navState.CB;

    if ConfGnssEng.USE_SBAS
        [sbasFc,fcStatus] = sbasInfo.getFastCorr(svId);
    end

    satClockCorr = constGps.c * orbitData.dt_sv;
    sagnacPrCorr = deriveSagnacPrCorr(navState,orbitData);
    ionoCorr = constGps.c * deriveKlobucharIonoCorr(navState,orbitData,auxSatData);
    prCorr = prCorr - CB + satClockCorr - sagnacPrCorr - ionoCorr;
end

