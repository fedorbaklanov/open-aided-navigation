classdef SbasData    
    properties
        svId = uint8(0);
        svList = uint8(zeros(1,51)); % An list of SVs for which corrections are broadcast, index corresponds to the number of nonzero bit in PRN mask
        svListIODP = uint8(255); % IODP of PRN mask, 255 is invalid value
        fcData = repmat(SbasFc,1,51); % Fast corrections data
        UDRE = repmat(uint8(255),1,51); % User differential range error, 255 is invalid value
    end
end

