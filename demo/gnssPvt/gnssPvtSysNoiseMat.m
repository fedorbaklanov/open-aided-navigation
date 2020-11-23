function [Q] = gnssPvtSysNoiseMat(x,dTtag,esMap)
    Q = zeros(esMap.LEN,esMap.LEN);
    dTtagSec = 1e-6 * double(dTtag);
    % Maximum expected platform acceleration serves as a basis for position
    % and velocity noise derivation. Other approaches are also valid and
    % may be even more efficient.
    max_accel = 3;
    var_vel = (max_accel)^2;
    var_pos = (max_accel / 2 * dTtagSec^2)^2;
    Q(esMap.V_EX,esMap.V_EX) = var_vel * dTtagSec;
    Q(esMap.V_EY,esMap.V_EY) = var_vel * dTtagSec;
    Q(esMap.V_EZ,esMap.V_EZ) = var_vel * dTtagSec;
    Q(esMap.POS_EX,esMap.V_EX) = 0.5 * var_vel * dTtagSec^2;
    Q(esMap.V_EX,esMap.POS_EX) = 0.5 * var_vel * dTtagSec^2;
    Q(esMap.POS_EY,esMap.V_EY) = 0.5 * var_vel * dTtagSec^2;
    Q(esMap.V_EY,esMap.POS_EY) = 0.5 * var_vel * dTtagSec^2;
    Q(esMap.POS_EZ,esMap.V_EZ) = 0.5 * var_vel * dTtagSec^2;
    Q(esMap.V_EZ,esMap.POS_EZ) = 0.5 * var_vel * dTtagSec^2;
    Q(esMap.POS_EX,esMap.POS_EX) = 0.3333 * var_vel * dTtagSec^3 + var_pos;
    Q(esMap.POS_EY,esMap.POS_EY) = 0.3333 * var_vel * dTtagSec^3 + var_pos;
    Q(esMap.POS_EZ,esMap.POS_EZ) = 0.3333 * var_vel * dTtagSec^3 + var_pos;

    % Noise variances for clock bias and drift are relatively large.
    % Motivation: handle wide variety of smartphones. Oscilator quality may
    % be different, so pessimistic values are used.
    var_cd = 30^2;
    var_cb = 100^2;
    Q(esMap.CD,esMap.CD) = var_cd * dTtagSec;
    Q(esMap.CB,esMap.CD) = 0.5 * var_cd * dTtagSec^2;
    Q(esMap.CD,esMap.CB) = 0.5 * var_cd * dTtagSec^2;
    Q(esMap.CB,esMap.CB) = 0.3333 * var_cd * dTtagSec^3 + var_cb * dTtagSec;
end

