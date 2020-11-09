function [q3] = lib_quatMult(q1,q2)
    q3 = zeros(4,1);
    q3(1) = q1(1) * q2(1) - q1(2:4)' * q2(2:4);
    q3(2:4) = q1(1) * q2(2:4) + q2(1) * q1(2:4) + cross(q1(2:4), q2(2:4));
end

