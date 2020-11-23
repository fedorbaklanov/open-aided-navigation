function [orbitDB] = prepOrbitData(gnssMeasDB)
    global gpsBcDB;

    orbitDB = OrbitDB;
    orbitDB.rcvTow = 1e-9 * gnssMeasDB.ttagRcv;

    % loop through all the slots af the measurement DB
    for i=1:1:ConfGnssEng.MAX_SIGMEAS_NUM
        if gnssMeasDB.meas(i).prValid
            switch gnssMeasDB.meas(i).gnssId
                case GnssId.GPS
                    slotNum = getBroadcastDBslotNum(gnssMeasDB.meas(i).gnssId, gnssMeasDB.meas(i).svId);
                    for j=1:1:2
                        t_st = driveGpsSigTransmTime(gnssMeasDB.meas(i),1e-9 * gnssMeasDB.ttagRcv);
                        if orbitDB.svOrbitData(slotNum).valid
                            % we enter this condition at the second iteration
                            t_st = t_st - orbitDB.svOrbitData(slotNum).dt_sv;
                        end
                        orbitDB.svOrbitData(slotNum) = deriveGpsSatPosVel(gpsBcDB(slotNum), t_st);
                    end
                otherwise
                    % do nothing
            end
        end
    end
end

