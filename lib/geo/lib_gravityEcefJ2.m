function [g_e] = lib_gravityEcefJ2(x_e,datum)
    g_e = zeros(3,1);

    tmp1 = sqrt(x_e' * x_e);

    if tmp1 > 0
        r2 = tmp1 * tmp1;
        r3 = tmp1 * r2;

        tmp1 = datum.GM / r3;
        tmp2 = 1.5 * (datum.a * (datum.a * datum.J2)) / r2;
        tmp3 = 5 / r2 * (x_e(3) * x_e(3));

        g_e = tmp1 * (-x_e - tmp2 * ([x_e(1); x_e(2); 3 * x_e(3)] -...
            tmp3 * x_e));

        tmp1 = datum.omega_ie * datum.omega_ie;
        g_e(1) = g_e(1) + tmp1 * x_e(1);
        g_e(2) = g_e(2) + tmp1 * x_e(2);
    end
end

