function handleUbxRxm(ubxRxmMsg)
    global gnssMeasDb;
    global isNewEpoch;

    switch ubxRxmMsg.id
        case hex2dec('15')
            gnssMeas = parseUbxRxmRawx(ubxRxmMsg);
            gnssMeasDb = gnssMeasDb.addData(gnssMeas, SensorType.GNSS_RAW);
            isNewEpoch = true;
        case hex2dec('13')
            ubxSfrbxMsg = parseUbxRxmSfrbx(ubxRxmMsg);
            handleUbxSubframeMsg(ubxSfrbxMsg);
        otherwise
            % do nothing
    end
end

