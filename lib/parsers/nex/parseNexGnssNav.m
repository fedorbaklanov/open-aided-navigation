function [nexNavData] = parseNexGnssNav(nexGnssNavMsg)
    nexNavData = [];

    nexNavData.svId = typecast(nexGnssNavMsg.payload(1:4),'int32');
    nexNavData.navMsgType = nexGnssNavMsg.payload(5);
    nexNavData.data = nexGnssNavMsg.payload(6:end);
end

