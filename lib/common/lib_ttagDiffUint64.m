function [dTtag] = lib_ttagDiffUint64(ttag1,ttag2)
    if ttag1 == ttag2
        dTtag = 0;
    elseif ttag1 > ttag2
        dTtag = double(ttag1 - ttag2);
    else
        dTtag = double(ttag2 - ttag1);
    end
end

