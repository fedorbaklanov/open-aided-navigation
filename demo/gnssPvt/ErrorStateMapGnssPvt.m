classdef ErrorStateMapGnssPvt  
    properties (Constant)
        LEN = uint8(8)
        POS_EX = uint8(1)
        POS_EY = uint8(2)
        POS_EZ = uint8(3)
        POS_E = uint8(1:3)
        CB = uint8(4)
        V_EX = uint8(5)
        V_EY = uint8(6)
        V_EZ = uint8(7)
        V_E = uint8(5:7)
        CD = uint8(8)
    end
end

