function [lat, lon, height] = lib_ecefToLlh(x_ecef, datum)
    a2 = datum.a * datum.a;
    b2 = datum.b * datum.b;
    z2 = x_ecef(3) * x_ecef(3);
    r2 = x_ecef(1) * x_ecef(1) + x_ecef(2) * x_ecef(2);
    r = sqrt(r2);

    F = 54 * b2 * z2;
    G = r2 + (1 - datum.e2) * z2 - datum.e2 * (a2 - b2);
    tmp = datum.e2 * datum.e2;
    c = tmp * F * r2 / (G * G * G);
    s = (1 + c + sqrt(c * c + 2 * c))^(1/3);
    P = F / (3 * (s + 1 / s + 1)^2 * G * G);
    Q = sqrt(1 + 2 * tmp * P);
    r0 = -P * datum.e2 * r / (1 + Q) +...
        sqrt(0.5 * a2 * (1 + 1 / Q) - P * (1 - datum.e2) * z2 / (Q * (1 + Q)) -...
        P * r2 * 0.5);
    tmp = (r - datum.e2 * r0)^2;
    U = sqrt(tmp + z2);
    V = sqrt(tmp + (1 - datum.e2) * z2);
    tmp = 1 / (datum.a * V);
    z0 = b2 * x_ecef(3) * tmp;

    height = U * (1 - b2 * tmp);
    tmp = a2 / b2 - 1; % Second eccentricity squared
    lat = atan2(x_ecef(3) + tmp * z0, r);
    lon = atan2(x_ecef(2), x_ecef(1));
end

