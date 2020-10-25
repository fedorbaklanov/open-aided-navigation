classdef GnssData
    properties
        ttagRcv = 0; % GNSS receiver clock time (time of week), [ns]
        ttagUc = 0; % Microcontroller time, [ns]
        ttagRcvValid = false; % Validity of GNSS receiver clock time: true -- valid, false -- invalid
        ttagUcValid = false; % Validity of microcontroller time: true -- valid, false -- invalid
        ttagRcvReset = false; % GNSS receiver clock realigned this epoch: true -- yes, false -- no.
        ttagUcReset = false; % Microcontroller clock realigned this epoch: true -- yes, false -- no.
        numMeas = uint8(0); % Number of measurements
        meas = repmat(GnssRawMeas,1,ConfGnssEng.MAX_SIGMEAS_NUM);
    end
end

