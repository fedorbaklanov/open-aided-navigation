function [sigma_ura] = calcSigmaFromURA(ura)
    if ura <= 6
        sigma_ura = 2^(1 + double(ura) / 2);
    elseif 6 < ura && ura < 15
        sigma_ura = 2^(ura - 2);
    else
        sigma_ura = 0;
    end
end

