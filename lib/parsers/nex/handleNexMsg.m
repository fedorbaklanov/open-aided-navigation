function handleNexMsg(nexMsg)
    switch nexMsg.msgGroup
        case hex2dec('2')
            handleNexGnssGrp(nexMsg);
        otherwise
            % do nothing
    end
end

