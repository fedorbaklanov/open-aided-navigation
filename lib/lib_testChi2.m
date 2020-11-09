function [needToReject] = lib_testChi2(res,P,H,R)
    needToReject = false;
    N = size(H,1);
    resCov = H * P * H' + R;
    for i=1:1:N
        if abs(res(i)) > 3 * sqrt(resCov(i,i))
            needToReject = true;
        end
    end
end

