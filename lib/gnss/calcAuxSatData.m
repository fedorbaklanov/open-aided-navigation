function [auxSatData] = calcAuxSatData(orbitData,prevState)
    auxSatData = AuxSatData;

    auxSatData.valid = true;
    auxSatData.estRange = sqrt((orbitData.POS_x - prevState.POS_x)^2 +...
                               (orbitData.POS_y - prevState.POS_y)^2 +...
                               (orbitData.POS_z - prevState.POS_z)^2);
    auxSatData.los_e(1) = (orbitData.POS_x - prevState.POS_x) / auxSatData.estRange;
    auxSatData.los_e(2) = (orbitData.POS_y - prevState.POS_y) / auxSatData.estRange;
    auxSatData.los_e(3) = (orbitData.POS_z - prevState.POS_z) / auxSatData.estRange;

    auxSatData.estRangeRate = auxSatData.los_e' * ([orbitData.v_x - prevState.v_x;...
                                                    orbitData.v_y - prevState.v_y;...
                                                    orbitData.v_z - prevState.v_z]);

    [lat, lon, ~] = lib_ecefToLlh([prevState.POS_x; prevState.POS_y; prevState.POS_z], Wgs84);
    C_ne = lib_dcmEcefToNed(lat, lon);
    los_NWU = diag([1; -1; -1]) * C_ne * auxSatData.los_e;

    auxSatData.El = asin(los_NWU(3));
    auxSatData.Az = atan2(los_NWU(2), los_NWU(1));

    if (auxSatData.Az < 0)
        auxSatData.Az = auxSatData.Az + 2 * pi;
    end
end

