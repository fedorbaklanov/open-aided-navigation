function [stateVec] = getApproxState(navState,measDB,orbitDB)
    if navState.valid
        stateVec = [navState.POS_x; navState.POS_y; navState.POS_z; navState.CB;...
            navState.v_x; navState.v_y; navState.v_z; navState.CD];
    else
        % derive approximate position
        prevState = NavState;
        satCount = 0;

        for i=1:1:ConfGnssEng.MAX_SIGMEAS_NUM
            if measDB.meas(i).prValid && measDB.meas(i).gnssId == GnssId.GPS
                slotNum = getBroadcastDBslotNum(measDB.meas(i).gnssId, measDB.meas(i).svId);

                if slotNum > 0 && orbitDB.svOrbitData(slotNum).valid
                    prevState.POS_x = prevState.POS_x + orbitDB.svOrbitData(slotNum).POS_x;
                    prevState.POS_y = prevState.POS_y + orbitDB.svOrbitData(slotNum).POS_y;
                    prevState.POS_z = prevState.POS_z + orbitDB.svOrbitData(slotNum).POS_z;
                    satCount = satCount + 1;
                end
            end
        end

        if satCount > 0
            prevState.POS_x = prevState.POS_x / satCount;
            prevState.POS_y = prevState.POS_y / satCount;
            prevState.POS_z = prevState.POS_z / satCount;

            normPosE = sqrt(prevState.POS_x^2 + prevState.POS_y^2 + prevState.POS_z^2);

            R = 6356000;
            stateVec = R / normPosE * [prevState.POS_x; prevState.POS_y; prevState.POS_z; 0;...
                0; 0; 0; 0];
        end
    end
end

