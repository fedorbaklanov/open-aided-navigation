function measDb = handleNexMsg(nexMsg,measDb)
    switch nexMsg.msgGroup
        case hex2dec('2')
            measDb = handleNexGnssGrp(nexMsg,measDb);
        otherwise
            % do nothing
    end
end

