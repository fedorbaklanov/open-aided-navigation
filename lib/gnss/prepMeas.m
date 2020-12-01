function [obsDB] = prepMeas(gnssMeasDB,orbitDB,auxSatDataDB,navState)
    global gpsBcDB;
    obsDB = GnssObsDB;

    nextFreeSlot = 1;

    % handle pseudoranges
    for i=1:1:gnssMeasDB.numMeas
        % Prepare pseudoranges
        if gnssMeasDB.meas(i).prValid && gnssMeasDB.meas(i).gnssId == GnssId.GPS
            gnssId = gnssMeasDB.meas(i).gnssId;
            svId = gnssMeasDB.meas(i).svId;
            slotNum = getBroadcastDBslotNum(gnssId,svId); % 0 is an invalid value of slotNum
            svOk = false;
            svEl = 0;

            % check if satellite is ok according to broadcast message
            if slotNum > 0
                svOk = checkGpsSv(gpsBcDB(slotNum));
                svEl = auxSatDataDB(slotNum).El * 180/pi;
            end

            % use satellite for positioning if
            %    1. its status is good
            %    2. we already have orbit data for it
            %    3. elevation is at least 10 degrees
            %    4. there is one more free slot in obsDB
            if (svOk &&...
                orbitDB.svOrbitData(slotNum).valid &&...
                svEl >= 10 &&...
                nextFreeSlot < obsDB.maxObsCount)

                obsDB.obs(nextFreeSlot).type = ObsType.PR;
                obsDB.obs(nextFreeSlot).val = gnssMeasDB.meas(i).pr;
                obsDB.obs(nextFreeSlot).gnssId = gnssId;
                obsDB.obs(nextFreeSlot).svId = svId;

                [prCorr,ionoApplied] = getPrCorr(svId,orbitDB.svOrbitData(slotNum),auxSatDataDB(slotNum),navState);
                obsDB.obs(nextFreeSlot).val = obsDB.obs(nextFreeSlot).val + prCorr;

                % derive observation variance, it is scaled with inverse
                % elevation angle
                ionoVar = 0; % placeholder
                ura = gpsBcDB(slotNum).svAcc;
                sigma_ura = calcSigmaFromURA(ura);
                obsDB.obs(nextFreeSlot).var =...
                    (gnssMeasDB.meas(i).prStd^2 + sigma_ura^2 + ionoVar) / (sin(pi/180 * svEl))^2;

                nextFreeSlot = nextFreeSlot + 1;
                obsDB.obsCount = obsDB.obsCount + 1;
            end
        end

        % Prepare Doppler measurements
        if gnssMeasDB.meas(i).rrValid && gnssMeasDB.meas(i).gnssId == GnssId.GPS
            gnssId = gnssMeasDB.meas(i).gnssId;
            svId = gnssMeasDB.meas(i).svId;
            slotNum = getBroadcastDBslotNum(gnssId,svId); % 0 is an invalid value of slotNum
            svOk = false;
            svEl = 0;

            % check if satellite is ok according to broadcast message
            if slotNum > 0
                svOk = checkGpsSv(gpsBcDB(slotNum));
                svEl = auxSatDataDB(slotNum).El * 180/pi;
            end

            % use satellite for positioning if
            %    1. its status is good
            %    2. we already have orbit data for it
            %    3. elevation is at least 10 degrees
            %    4. there is one more free slot in obsDB
            if (svOk &&...
                orbitDB.svOrbitData(slotNum).valid &&...
                svEl >= 10 &&...
                nextFreeSlot < obsDB.maxObsCount)

                constGps = getGpsConstants();
                obsDB.obs(nextFreeSlot).type = ObsType.DO;
                obsDB.obs(nextFreeSlot).val = double(gnssMeasDB.meas(i).rr) - navState.CD + constGps.c * orbitDB.svOrbitData(slotNum).dt_sv_dot;
                obsDB.obs(nextFreeSlot).gnssId = gnssId;
                obsDB.obs(nextFreeSlot).svId = svId;
                obsDB.obs(nextFreeSlot).var =...
                    gnssMeasDB.meas(i).rrStd^2 / (sin(pi/180 * svEl))^2;
                nextFreeSlot = nextFreeSlot + 1;
                obsDB.obsCount = obsDB.obsCount + 1;
            end
        end
    end
end

