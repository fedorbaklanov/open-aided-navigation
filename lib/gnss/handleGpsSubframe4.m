% subrame 4 can contain different pages, so it is needed to handle it
% properly
function handleGpsSubframe4(subframe)
    global gpsBcIonoParams;
    dataId = getGpsSubrameDataId(subframe);
    svId = getGpsSubrameSvId(subframe);
    
    % this is the only valid data id according to GPS ICD
    if dataId == 1
        switch svId
            % ionosphere and UTC data
            case 56
                subframe4page18Data = parseGpsSubframe4Page18(subframe);
                gpsBcIonoParams.valid = true;
                gpsBcIonoParams.alpha0 = 1 / 2^30 * double(subframe4page18Data.alpha0);
                gpsBcIonoParams.alpha1 = 1 / 2^27 * double(subframe4page18Data.alpha1);
                gpsBcIonoParams.alpha2 = 1 / 2^24 * double(subframe4page18Data.alpha2);
                gpsBcIonoParams.alpha3 = 1 / 2^24 * double(subframe4page18Data.alpha3);
                gpsBcIonoParams.beta0 = 2^11 * double(subframe4page18Data.beta0);
                gpsBcIonoParams.beta1 = 2^14 * double(subframe4page18Data.beta1);
                gpsBcIonoParams.beta2 = 2^16 * double(subframe4page18Data.beta2);
                gpsBcIonoParams.beta3 = 2^16 * double(subframe4page18Data.beta3);
            otherwise
        end
    end
end

