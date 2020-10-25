% Copyright 2020 FEDOR BAKLANOV
% Permission is hereby granted, free of charge, to any person obtaining 
% a copy of this software and associated documentation files
% (the "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
% 
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.

%% Function Name: importNexFile
%
% Assumptions: None
%
% Inputs:
%   filePath - string containing a full path to a .nex file
%
% Outputs:
%   nexMsg - a cell array of messages
%
% $Date: June 12, 2020
% _________________________________________________________________________
function [nexMsg] = importNexFile(filePath)
    nexMsg = {};
    
    try
        fileId = fopen(filePath,'r');
        
        if fileId == -1
            disp('Cannot open desired file!');
            return;            
        end
        msgCount = 0;
        
        while ~feof(fileId)
            marker1 = uint8(0);
            marker2 = uint8(0);
            
            [tmp, cnt] = fread(fileId,1,'uint8=>uint8');
            
            if cnt == 1
                marker1 = tmp;
            end
            
            if marker1 == uint8(hex2dec('4E'))
                [tmp, cnt] = fread(fileId,1,'uint8=>uint8');
                if cnt == 1
                    marker2 = tmp;
                end
            end
            
            if marker2 == uint8(hex2dec('45'))
                nexMsg{end+1} = struct;
                nexMsg{end}.msgGroup = fread(fileId,1,'uint8=>uint8');
                nexMsg{end}.msgType = fread(fileId,1,'uint8=>uint8');
                nexMsg{end}.crcType = fread(fileId,1,'uint8=>uint8');
                nexMsg{end}.payloadLen = fread(fileId,1,'uint32=>uint32',0,'l');
                nexMsg{end}.payload = fread(fileId,nexMsg{end}.payloadLen,'uint8=>uint8');                
                msgCount = msgCount + 1;
            end
        end        
        
        fprintf('\n\n##########\n %d messages successfully extracted! \n##########\n\n', msgCount);
        fclose(fileId);
    catch
        disp('Unknown exception happened!');
    end
end