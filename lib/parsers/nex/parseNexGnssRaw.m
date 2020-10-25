function [gnssData] = parseNexGnssRaw(nexGnssRawMsg)
    gnssData = GnssData;

    gnssData.ttagRcv = cast(typecast(nexGnssRawMsg.payload(2:9),'uint64'),'double');
    gnssData.numMeas = nexGnssRawMsg.payload(1);

    tmp = nexGnssRawMsg.payload(18);
    gnssData.ttagRcvValid = logical(bitget(tmp, 1));
    gnssData.ttagRcvReset = logical(bitget(tmp, 3));

    for i=1:1:min(uint32(gnssData.numMeas), ConfGnssEng.MAX_SIGMEAS_NUM)
        gnssData.meas(i).gnssId = nexGnssRawMsg.payload(19 + 44 * (i-1))-1;
        gnssData.meas(i).svId = nexGnssRawMsg.payload(20 + 44 * (i-1));

        gnssData.meas(i).pr = typecast(nexGnssRawMsg.payload((21 + 44 * (i-1)):(28 + 44 * (i-1))),'double');
        gnssData.meas(i).rr = typecast(nexGnssRawMsg.payload((29 + 44 * (i-1)):(36 + 44 * (i-1))),'double');
        gnssData.meas(i).cp = typecast(nexGnssRawMsg.payload((37 + 44 * (i-1)):(44 + 44 * (i-1))),'double');

        gnssData.meas(i).cn0 = nexGnssRawMsg.payload(57 + 44 * (i-1));
        gnssData.meas(i).prStd = 1e-9 * typecast(nexGnssRawMsg.payload((45 + 44 * (i-1)):(48 + 44 * (i-1))),'single');
        gnssData.meas(i).rrStd = typecast(nexGnssRawMsg.payload((49 + 44 * (i-1)):(52 + 44 * (i-1))),'single');
        gnssData.meas(i).cpStd = typecast(nexGnssRawMsg.payload((53 + 44 * (i-1)):(56 + 44 * (i-1))),'single');

        tmp = nexGnssRawMsg.payload(62 + 44 * (i-1)); % bitfield with flags
        gnssData.meas(i).prValid = logical(bitget(tmp, 1));
        gnssData.meas(i).rrValid = logical(bitget(tmp, 2));
        gnssData.meas(i).cpValid = logical(bitget(tmp, 3));

        if bitget(tmp, 4) == 1
            % carrier frequency is available
            freqFloat = typecast(nexGnssRawMsg.payload((58 + 44 * (i-1)):(61 + 44 * (i-1))),'single');
            gnssData.meas(i).freq = 1000 * uint32(round(freqFloat * 0.001));
        end
    end
end

