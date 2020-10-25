classdef GnssRawMeas
    properties
        pr = 0; % Pseudorange, [m]
        cp = 0; % Carrier phase, [cycles]
        rr = 0; % Pseudorange rate, [m/s]
        prValid = false; % Pseudorange validity flag: true -- valid, false -- invalid
        cpValid = false; % Carrier phase validity flag: true -- valid, false -- invalid
        rrValid = false; % Pseudorange rate validity flag: true -- valid, false -- invalid
        prStd = 0; % Pseudorange standard deviation, [m]
        cpStd = 0; % Carrier phase standard deviation, [cycles]
        rrStd = 0; % Pseudorange rate standard deviation, [m/s]
        gnssId = uint8(0); % GNSS identifier
        svId = uint8(0); % Space vehicle identifier
        freq = uint32(0); % Signal frequency, [Hz]
        cn0 = uint8(0); % C/N0, [dB-Hz]
    end
end

