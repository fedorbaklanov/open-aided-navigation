function handleGpsSubframe(subframe, slotNum)
    global gpsBcDB;

    sfrId = getSubrameId(subframe);

    gpsBcDB(slotNum).integStatFlag = parseGpsTLM(subframe);
    [gpsBcDB(slotNum).antiSpoofFlag, gpsBcDB(slotNum).alertFlag] = parseGpsHOW(subframe);

    switch sfrId
        case 1
            subframe1Data = parseGpsSubframe1(subframe);
            gpsBcDB(slotNum).codeOnL2 = subframe1Data.codeOnL2;
            gpsBcDB(slotNum).weekNum = subframe1Data.weekNum;
            gpsBcDB(slotNum).dataFlagL2P = subframe1Data.dataFlagL2P;
            gpsBcDB(slotNum).svAcc = subframe1Data.svAcc;
            gpsBcDB(slotNum).svHealth = subframe1Data.svHealth;
            gpsBcDB(slotNum).TGD = 1 / 2^31 * cast(subframe1Data.TGD,'double');
            gpsBcDB(slotNum).IODC = subframe1Data.IODC;
            gpsBcDB(slotNum).toc = 2^4 * cast(subframe1Data.toc,'double');
            gpsBcDB(slotNum).af2 = 1 / 2^55 * cast(subframe1Data.af2,'double');
            gpsBcDB(slotNum).af1 = 1 / 2^43 * cast(subframe1Data.af1,'double');
            gpsBcDB(slotNum).af0 = 1 / 2^31 * cast(subframe1Data.af0,'double');
        case 2
            subframe2Data = parseGpsSubframe2(subframe);
            constGps = getGpsConstants();
            gpsBcDB(slotNum).IODEsfr2 = subframe2Data.IODE;
            gpsBcDB(slotNum).Crs = 1 / 2^5 * cast(subframe2Data.Crs,'double');
            gpsBcDB(slotNum).dn = 1 / 2^43 * constGps.pi * cast(subframe2Data.dn,'double');
            gpsBcDB(slotNum).M0 = 1 / 2^31 * constGps.pi * cast(subframe2Data.M0,'double');
            gpsBcDB(slotNum).Cuc = 1 / 2^29 * cast(subframe2Data.Cuc,'double');
            gpsBcDB(slotNum).e = 1 / 2^33 * cast(subframe2Data.e,'double');
            gpsBcDB(slotNum).Cus = 1 / 2^29 * cast(subframe2Data.Cus,'double');
            gpsBcDB(slotNum).sqrtA = 1 / 2^19 * cast(subframe2Data.sqrtA,'double');
            gpsBcDB(slotNum).toe = 2^4 * cast(subframe2Data.toe,'double');
            gpsBcDB(slotNum).fitIntervalFlag = subframe2Data.fitIntervalFlag;
            gpsBcDB(slotNum).AODO = subframe2Data.AODO;
        case 3
            subframe3Data = parseGpsSubframe3(subframe);
            constGps = getGpsConstants();
            gpsBcDB(slotNum).Cic = 1 / 2^29 * cast(subframe3Data.Cic,'double');
            gpsBcDB(slotNum).Omega0 = 1 / 2^31 * constGps.pi * cast(subframe3Data.Omega0,'double');
            gpsBcDB(slotNum).Cis = 1 / 2^29 * cast(subframe3Data.Cis,'double');
            gpsBcDB(slotNum).i0 = 1 / 2^31 * constGps.pi * cast(subframe3Data.i0,'double');
            gpsBcDB(slotNum).Crc = 1 / 2^5 * cast(subframe3Data.Crc,'double');
            gpsBcDB(slotNum).omega = 1 / 2^31 * constGps.pi * cast(subframe3Data.omega,'double');
            gpsBcDB(slotNum).dotOmega = 1 / 2^43 * constGps.pi * cast(subframe3Data.dotOmega,'double');
            gpsBcDB(slotNum).IODEsfr3 = subframe3Data.IODE;
            gpsBcDB(slotNum).IDOT = 1 / 2^43 * constGps.pi * cast(subframe3Data.IDOT,'double');
        case 4
            handleGpsSubframe4(subframe);
        case 5
            % do nothing
        otherwise
            % do nothing
    end
end

