function handleUbxMsg(ubxMsg)
    switch ubxMsg.class
        case hex2dec('1')
            handleUbxNav(ubxMsg);
        case hex2dec('2')
            handleUbxRxm(ubxMsg);
        otherwise
            % do nothing
    end
end

