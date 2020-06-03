function handleUbxNav(ubxNavMsg)
    global Ref;
    switch ubxNavMsg.id
        case hex2dec('7')
            PVT = parseUbxNavPvt(ubxNavMsg);
            Ref{end+1} = PVT;
        otherwise
            % do nothing
    end
end

