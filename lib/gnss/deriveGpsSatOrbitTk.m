function [tk] = deriveGpsSatOrbitTk(t_st,toe)
    tk = t_st - toe;
    
    if tk > 302400
        tk = tk - 604800;
    elseif tk < -302400
        tk = tk + 604800;
    else
        % do nothing
    end
end

