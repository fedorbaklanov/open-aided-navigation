function handleUbxMsg(ubxMsg)
    switch ubxMsg.class
        case hex2dec('1')
            handleUbxNav(ubxMsg);
        otherwise
            % do nothing
    end
end

