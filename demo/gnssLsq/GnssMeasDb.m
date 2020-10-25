classdef GnssMeasDb < MeasDb
    properties (SetAccess='private', GetAccess='public')
        valid = false;
        ttagRcv = 0; % GNSS receiver clock time (time of week), [ns]
        ttagRcvValid = false; % Validity of GNSS receiver clock time: true -- valid, false -- invalid
        ttagRcvReset = false; % GNSS receiver clock realigned this epoch: true -- yes, false -- no.
        numMeas = uint8(0); % Number of measurements
        meas = repmat(GnssRawMeas,1,ConfGnssEng.MAX_SIGMEAS_NUM);
    end
    methods
        function obj = GnssMeasDb()
        end

        function obj = addData(obj,data,sensorType)
            switch sensorType
                case SensorType.GNSS_RAW
                    obj.valid = true;
                    obj.ttagRcv = data.ttagRcv;
                    obj.ttagRcvValid = data.ttagRcvValid;
                    obj.ttagRcvReset = data.ttagRcvReset;
                    obj.numMeas = data.numMeas;
                    obj.meas = data.meas;
                otherwise
                    % do nothing
            end
        end
    end
end

