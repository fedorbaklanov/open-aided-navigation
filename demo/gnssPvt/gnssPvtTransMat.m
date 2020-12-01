function [Phi] = gnssPvtTransMat(dTtag,esMap)
    Phi = eye(esMap.LEN,esMap.LEN);
    dTtagSec = 1e-6 * double(dTtag);
    Phi(esMap.POS_EX,esMap.V_EX) = dTtagSec;
    Phi(esMap.POS_EY,esMap.V_EY) = dTtagSec;
    Phi(esMap.POS_EZ,esMap.V_EZ) = dTtagSec;
    Phi(esMap.CB,esMap.CD) = dTtagSec;
end

