classdef GpsBcData   
    properties
        integStatFlag = uint8(0);
        antiSpoofFlag = uint8(0);
        alertFlag = uint8(0);
        codeOnL2 = uint8(0);
        weekNum = uint16(0);
        dataFlagL2P = uint8(0);
        svAcc = uint8(0);
        svHealth = uint8(0);
        TGD = double(0);
        IODC = uint16(0);
        toc = double(0);
        af2 = double(0);
        af1 = double(0);
        af0 = double(0);
        IODEsfr2 = uint8(0);
        Crs = double(0);
        dn = double(0);
        M0 = double(0);
        Cuc = double(0);
        e = double(0);
        Cus = double(0);
        sqrtA = double(0);
        toe = double(0);
        fitIntervalFlag = uint8(0);
        AODO = uint8(0);
        Cic = double(0);
        Omega0 = double(0);
        Cis = double(0);
        i0 = double(0);
        Crc = double(0);
        omega = double(0);
        dotOmega = double(0);
        IODEsfr3 = uint8(0);
        IDOT = double(0);
    end
end

