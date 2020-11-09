function [q_ne] = lib_quatEcefToNed(lat,lon)
    tmp = 0.5 * lon;
    q_1 = [cos(tmp); 0; 0; -sin(tmp)];
    tmp = 0.5 * (lat + 0.5 * pi);
    q_2 = [cos(tmp); 0; sin(tmp); 0];
    q_ne = lib_quatMult(q_2, q_1);
end

