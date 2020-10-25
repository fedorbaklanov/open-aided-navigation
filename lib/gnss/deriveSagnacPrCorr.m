function [sagnacPrCorr] = deriveSagnacPrCorr(navState,svOrbitData)
    sagnacPrCorr = 0;

    if navState.valid && svOrbitData.valid
        constGps = getGpsConstants();
        sagnacPrCorr = constGps.Omega_ie / constGps.c * (svOrbitData.POS_x * navState.POS_y - svOrbitData.POS_y * navState.POS_x);
    end
end

