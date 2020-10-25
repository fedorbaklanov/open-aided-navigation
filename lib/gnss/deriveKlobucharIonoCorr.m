function [T_iono] = deriveKlobucharIonoCorr(navState,orbitData,auxSatData)
    global gpsBcIonoParams;
    T_iono = 0;

    if gpsBcIonoParams.valid
        [lat, lon, ~] = lib_ecefToLlh([navState.POS_x; navState.POS_y; navState.POS_z], Wgs84);

        phi_u = lat / pi;
        lambda_u = lon / pi;
        E = auxSatData.El / pi;
        A = auxSatData.Az / pi;

        psi = 0.0137 / (E + 0.11) - 0.022;

        phi_i = phi_u + psi * cos(A * pi);

        if phi_i > 0.416
            phi_i = 0.416;
        elseif phi_i < -0.416
            phi_i = -0.416;
        else
            % do nothing
        end

        lambda_i = lambda_u + psi * sin(A * pi) / cos(phi_i * pi);

        phi_m = phi_i + 0.064 * cos((lambda_i - 1.617) * pi);

        T = 4.32 * 10^4 * lambda_i + mod(orbitData.t_st,86400);

        if T >= 86400
            T = T - 86400;
        elseif T < 0
            T = T + 86400;
        else
            % do nothing
        end

        F = 1.0 + 16.0 * (0.53 - E)^3;

        PER = gpsBcIonoParams.beta0 + gpsBcIonoParams.beta1 * phi_m +...
            gpsBcIonoParams.beta2 * phi_m^2 + gpsBcIonoParams.beta3 * phi_m^3;

        if PER < 72000
            PER = 72000;
        end

        AMP = gpsBcIonoParams.alpha0 + gpsBcIonoParams.alpha1 * phi_m +...
            gpsBcIonoParams.alpha2 * phi_m^2 + gpsBcIonoParams.alpha3 * phi_m^3;

        if AMP < 0
            AMP = 0;
        end

        x = 2 * pi * (T - 50400) / PER;

        if abs(x) >= 1.57
            T_iono = F * (5e-9);
        else
            T_iono = F * ((5e-9) + AMP * (1 - x^2 / 2 + x^4 / 24));
        end
    end    
end

