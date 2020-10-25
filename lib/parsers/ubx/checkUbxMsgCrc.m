function [crcOk] = checkUbxMsgCrc(msg)
    [CK_A,CK_B] = calcUbxMsgCrc(msg);
    
    if CK_A == msg.crc(1) && CK_B == msg.crc(2)
        crcOk = true;
    else
        crcOk = false;
    end
end

