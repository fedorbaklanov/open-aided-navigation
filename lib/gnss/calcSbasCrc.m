function [crc] = calcSbasCrc(msg)
    crc = uint32(0);
    pln = uint32(hex2dec('1864CFB'));
    for i=1:1:8
        if i==8
            maxIter = 2;
            msg(i) = bitand(msg(i),uint32(hex2dec('c0000000')));
        else
            maxIter = 32;
        end
        crc = bitxor(crc,msg(i));
        for j=1:1:maxIter            
            if bitand(crc,uint32(hex2dec('80000000'))) > 0
                 crc  = bitxor(bitshift(crc,1),bitshift(pln,8));
            else
                 crc = bitshift(crc,1);
            end
        end
    end
    crc = bitand(bitshift(crc,-8),uint32(hex2dec('ffffff')));
end

