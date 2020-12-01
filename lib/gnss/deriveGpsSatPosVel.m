function [svOrbitData] = deriveGpsSatPosVel(gpsBcData,t_st)
    svOrbitData = SvOrbitData;

    if gpsBcData.IODC ~= 0 &&...
       gpsBcData.IODEsfr2 ~= 0 &&...
       gpsBcData.IODEsfr3 ~= 0 &&...
       gpsBcData.IODEsfr2 == gpsBcData.IODEsfr3 &&...
       gpsBcData.IODC == gpsBcData.IODEsfr3

        % Derivation of position
        svOrbitData.t_st = t_st;
        constGps = getGpsConstants();
        A = gpsBcData.sqrtA^2;
        n0 = sqrt(constGps.mu / A^3);

        tk = deriveGpsSatOrbitTk(t_st,gpsBcData.toe);

        n = n0 + gpsBcData.dn;
        Mk = gpsBcData.M0 + n * tk;

        Ek = solveKepler(Mk,gpsBcData.e);

        nuk = atan2((sqrt(1 - gpsBcData.e^2) * sin(Ek)) / (1 - gpsBcData.e * cos(Ek)),...
                    (cos(Ek) - gpsBcData.e) / (1 - gpsBcData.e * cos(Ek)));
        Phik = nuk + gpsBcData.omega;

        sin2Phik = sin(2 * Phik);
        cos2Phik = cos(2 * Phik);

        duk = gpsBcData.Cus * sin2Phik + gpsBcData.Cuc * cos2Phik;
        drk = gpsBcData.Crs * sin2Phik + gpsBcData.Crc * cos2Phik;
        dik = gpsBcData.Cis * sin2Phik + gpsBcData.Cic * cos2Phik;

        uk = Phik + duk;
        rk = A * (1 - gpsBcData.e * cos(Ek)) + drk;
        ik = gpsBcData.i0 + dik + (gpsBcData.IDOT) * tk;

        xkprime = rk * cos(uk);
        ykprime = rk * sin(uk);

        Omegak_dot = gpsBcData.dotOmega - constGps.Omega_ie;
        Omegak = gpsBcData.Omega0 + Omegak_dot * tk - constGps.Omega_ie * gpsBcData.toe;

        sinOmegak = sin(Omegak);
        cosOmegak = cos(Omegak);
        cosik = cos(ik);
        sinik = sin(ik);

        svOrbitData.POS_x = xkprime * cosOmegak - ykprime * cosik * sinOmegak;
        svOrbitData.POS_y = xkprime * sinOmegak + ykprime * cosik * cosOmegak;
        svOrbitData.POS_z = ykprime * sinik;

        t = deriveGpsSatClockT(t_st,gpsBcData.toc);
        svOrbitData.dt_sv_dot = gpsBcData.af1 + 2 * gpsBcData.af2 * t;
        svOrbitData.dt_sv = gpsBcData.af0 + gpsBcData.af1 * t + gpsBcData.af2 * t^2 + constGps.F * gpsBcData.e * gpsBcData.sqrtA * sin(Ek) - gpsBcData.TGD;

        % Derivation of velocity
        E_dot = n / (1 - gpsBcData.e * cos(Ek));
        Phi_dot = sin(nuk) / sin(Ek) * E_dot;

        rk_dot = A * gpsBcData.e * sin(Ek) * E_dot + 2 * Phi_dot * (gpsBcData.Crs * cos2Phik - gpsBcData.Crc * sin2Phik);
        uk_dot = Phi_dot * (1 + 2 * (gpsBcData.Cus * cos2Phik - gpsBcData.Cuc * sin2Phik));
        ik_dot = gpsBcData.IDOT + 2 * Phi_dot * (gpsBcData.Cis * cos2Phik - gpsBcData.Cic * sin2Phik);

        xkprime_dot = rk_dot * cos(uk) - rk * uk_dot * sin(uk);
        ykprime_dot = rk_dot * sin(uk) + rk * uk_dot * cos(uk);

        svOrbitData.v_x = xkprime_dot * cosOmegak - ykprime_dot * cosik * sinOmegak +...
            ik_dot * ykprime * sinik * sinOmegak -...
            Omegak_dot * (xkprime * sinOmegak + ykprime * cosik * cosOmegak);

        svOrbitData.v_y = xkprime_dot * sinOmegak + ykprime_dot * cosik * cosOmegak -...
            ik_dot * ykprime * sinik * cosOmegak -...
            Omegak_dot * (-xkprime * cosOmegak + ykprime * cosik * sinOmegak);

        svOrbitData.v_z = ykprime_dot * sinik + ik_dot * ykprime * cosik;

        svOrbitData.valid = true;
    end
end

