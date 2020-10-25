function [svOrbitData] = deriveGpsSatOrbit(gpsBcData,t_st)
    svOrbitData = SvOrbitData;

    if gpsBcData.IODC ~= 0 &&...
       gpsBcData.IODEsfr2 ~= 0 &&...
       gpsBcData.IODEsfr3 ~= 0 &&...
       gpsBcData.IODEsfr2 == gpsBcData.IODEsfr3 &&...
       gpsBcData.IODC == gpsBcData.IODEsfr3

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

        Omegak = gpsBcData.Omega0 + (gpsBcData.dotOmega - constGps.Omega_ie) * tk - constGps.Omega_ie * gpsBcData.toe;

        sinOmegak = sin(Omegak);
        cosOmegak = cos(Omegak);
        cosik = cos(ik);

        svOrbitData.POS_x = xkprime * cosOmegak - ykprime * cosik * sinOmegak;
        svOrbitData.POS_y = xkprime * sinOmegak + ykprime * cosik * cosOmegak;
        svOrbitData.POS_z = ykprime * sin(ik);

        t = deriveGpsSatClockT(t_st,gpsBcData.toc);
        svOrbitData.dt_sv = gpsBcData.af0 + gpsBcData.af1 * t + gpsBcData.af2 * t^2 + constGps.F * gpsBcData.e * gpsBcData.sqrtA * sin(Ek) - gpsBcData.TGD;
        svOrbitData.valid = true;
    end
end

