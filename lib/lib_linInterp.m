function [v,status] = lib_linInterp(v1,v2,ttag1,ttag2,ttag)
    status = true;
    v = zeros(size(v1));
    if ttag2 > ttag1 && ttag >= ttag1
        v = v1 + (v2 - v1) * double(ttag - ttag1) / double(ttag2 - ttag1);
    else
        status = false;
    end
end

