function [CK_A,CK_B] = calcUbxMsgCrc(msg)
    CK_A = uint32(0);
    CK_B = uint32(0);
    Buffer = [msg.class; msg.id; uint8(bitshift(bitshift(msg.len,8),-8)); uint8(bitshift(msg.len,-8)); msg.payload];
    N = length(Buffer);
    for i=1:1:N
        CK_A = CK_A + uint32(Buffer(i));
        CK_B = CK_B + CK_A;
    end
    CK_A = uint8(bitshift(bitshift(CK_A,24),-24));
    CK_B = uint8(bitshift(bitshift(CK_B,24),-24));
end

