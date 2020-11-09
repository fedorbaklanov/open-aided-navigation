function [dx,P] = lib_kfUpdateJoseph(P,obsDb,H)
    [errStateLen,~] = size(P);
    dx = zeros(errStateLen,1);

    for i=1:1:obsDb.obsCount
        if obsDb.obs(i).valid
            H_1 = H(i,:);
            r = obsDb.obs(i).var;
            s = H_1 * P * H_1' + obsDb.obs(i).var;        
            if s > 0
                K = (1 / s) * (P * H_1');
                dx = dx + K * (obsDb.obs(i).res - H_1 * dx);
                Tmp = (eye(errStateLen) - K * H_1);
                P = (Tmp * P) * Tmp' + r * (K * K');
            end
        end
    end
end

