function [Ek] = solveKepler(Mk,e)
    Ek = Mk;
    
    for i=1:1:20
        Ek_next = Mk + e * sin(Ek);
        
        if abs(Ek_next - Ek) <= 1e-8
            Ek = Ek_next;
            break;
        else
            Ek = Ek_next;
        end
    end
end

