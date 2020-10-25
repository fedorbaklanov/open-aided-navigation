function [t] = deriveGpsSatClockT(t_st,toc)
    t = t_st - toc;
    
    if t > 302400
        t = t - 604800;
    elseif t < -302400
        t = t + 604800;
    else
        % do nothing
    end
end

