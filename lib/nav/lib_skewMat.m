function [skewMat] = lib_skewMat(v)
    skewMat = [ 0,   -v(3),  v(2);
                v(3),    0, -v(1);
               -v(2), v(1),    0];
end

