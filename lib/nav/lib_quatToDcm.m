function [C] = lib_quatToDcm(q)
    C = zeros(3,3);
    q1_2 = q(2) * q(2);
    q2_2 = q(3) * q(3);
    q3_2 = q(4) * q(4);

    C(1,1) = 1 - 2 * (q2_2 + q3_2);
    C(2,2) = 1 - 2 * (q1_2 + q3_2);
    C(3,3) = 1 - 2 * (q1_2 + q2_2);

    tmp1 = q(2) * q(3);
    tmp2 = q(1) * q(4);

    C(1,2) = 2 * (tmp1 - tmp2);
    C(2,1) = 2 * (tmp1 + tmp2);

    tmp1 = q(2) * q(4);
    tmp2 = q(1) * q(3);

    C(1,3) = 2 * (tmp1 + tmp2);
    C(3,1) = 2 * (tmp1 - tmp2);

    tmp1 = q(3) * q(4);
    tmp2 = q(1) * q(2);

    C(2,3) = 2 * (tmp1 - tmp2);
    C(3,2) = 2 * (tmp1 + tmp2);
end

