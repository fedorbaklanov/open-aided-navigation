classdef InsGnssLooseMeasDb < MeasDb
    properties (SetAccess='private', GetAccess='public')
        accelBuf;
        gyroBuf;
        gnssBuf;
    end
    methods
        function obj = InsGnssLooseMeasDb(bufLen)
            obj.accelBuf = RingBuffer(AccelData,bufLen);
            obj.gyroBuf = RingBuffer(GyroData,bufLen);
            obj.gnssBuf = RingBuffer(GnssNavData,bufLen);
        end

        function obj = addData(obj,data,sensorType)
            switch sensorType
                case SensorType.ACCEL
                    obj.accelBuf = obj.accelBuf.addData(data,data.ttag);
                case SensorType.GYRO
                    obj.gyroBuf = obj.gyroBuf.addData(data,data.ttag);
                case SensorType.GNSS
                    obj.gnssBuf = obj.gnssBuf.addData(data,data.ttag);
                otherwise
                    % do nothing
            end
        end
    end
end

