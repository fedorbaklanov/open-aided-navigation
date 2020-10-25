function [wn,tow] = addToGpsTime(wnIn,towIn,dt)
    tow = towIn + dt;    
    if tow > 604800
        wn = wnIn + 1;
        tow = tow - 604800;
    elseif tow < 0
        tow = tow + 604800;
        wn = wnIn - 1;
    else
        wn = wnIn;
    end
end

