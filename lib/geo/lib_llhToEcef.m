function [x_ecef] = lib_llhToEcef(lat, lon, height, datum)
    x_ecef = zeros(3,1);
    [~, rN] = lib_ellipsoidCurvature(lat, datum);
    tmp = (rN + height) * cos(lat);
    x_ecef(1) = tmp * cos(lon);
    x_ecef(2) = tmp * sin(lon);
    x_ecef(3) = ((1 - datum.e2) * rN + height) * sin(lat);
end

