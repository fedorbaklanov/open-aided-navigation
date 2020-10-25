function [svCount] = countSat(gnssMeasDB,orbitDB)
    svCount = 0;
    for i=1:1:ConfGnssEng.MAX_SIGMEAS_NUM
        if gnssMeasDB.meas(i).prValid
            slotNum = getBroadcastDBslotNum(gnssMeasDB.meas(i).gnssId,gnssMeasDB.meas(i).svId);
            if slotNum > 0 && orbitDB.svOrbitData(slotNum).valid
                svCount = svCount + 1;
            end
        end
    end
end

