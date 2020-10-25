function [t_st] = driveGpsSigTransmTime(gnssMeas,rcvTow)
    constGps = getGpsConstants();
    t_st = rcvTow - gnssMeas.pr / constGps.c;
end

