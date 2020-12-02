function [y] = lib_lowPassFilter(x,time,tau)
    y = zeros(size(x));
    if tau > 0
        c = 1 / tau;
        for i=1:1:length(x)
            if i==1
                y(:,1) = x(:,1);
            else
                y(:,i) = y(:,i-1) + c * (time(i) - time(i-1)) * (x(:,i) - y(:,i-1));
            end
        end
    else
        y = nan(size(x));
    end
end

