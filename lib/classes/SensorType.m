classdef SensorType
    properties (Constant)
        NONE = uint8(0)
        ACCEL = uint8(1)
        GYRO = uint8(2)
        CAMERA = uint8(3)
        GNSS_RAW = uint8(4)
        GNSS = uint8(5)
        NAV_STATE = uint8(6)
    end
end

