classdef StateMapInsGnssLoose  
    properties (Constant)
        LEN = uint8(26)
        POS_EX = uint8(1)
        POS_EY = uint8(2)
        POS_EZ = uint8(3)
        POS_E = uint8(1:3)
        V_EX = uint8(4)
        V_EY = uint8(5)
        V_EZ = uint8(6)
        V_E = uint8(4:6)
        Q_ES0 = uint8(7)
        Q_ES1 = uint8(8)
        Q_ES2 = uint8(9)
        Q_ES3 = uint8(10)
        Q_ES = uint8(7:10)
        B_FX = uint8(11)
        B_FY = uint8(12)
        B_FZ = uint8(13)
        B_F = uint8(11:13)
        B_WX = uint8(14)
        B_WY = uint8(15)
        B_WZ = uint8(16)
        B_W = uint8(14:16)
        S_FX = uint8(17)
        S_FY = uint8(18)
        S_FZ = uint8(19)
        S_F = uint8(17:19)
        S_WX = uint8(20)
        S_WY = uint8(21)
        S_WZ = uint8(22)
        S_W = uint8(20:22)
        Q_CS0 = uint8(23)
        Q_CS1 = uint8(24)
        Q_CS2 = uint8(25)
        Q_CS3 = uint8(26)
        Q_CS = uint8(23:26)
    end
end

