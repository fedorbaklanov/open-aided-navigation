function [rM, rN] = lib_ellipsoidCurvature(lat, datum)
    tmp = sqrt(1 - datum.e2 * sin(lat)^2);
    rM = datum.a * (1 - datum.e2) / (tmp * tmp * tmp);
    rN = datum.a / tmp;
end

