function [C_ne] = lib_dcmEcefToNed(lat, lon)
    sinLat = sin(lat);
    cosLat = cos(lat);
    sinLon = sin(lon);
    cosLon = cos(lon);

    C_ne = [-sinLat * cosLon, -sinLat * sinLon, cosLat;
            -sinLon, cosLon, 0;
            -cosLat * cosLon, -cosLat * sinLon, -sinLat];
    end

