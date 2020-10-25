%% Function Name: lib_importNsrGyroFile
%
% Import gyroscope data from CSV file written by Nav Sensor Recorder
%
% Inputs:
%   filePath - string containing a full path to file
%
% Outputs:
%   accelData - AccelData structure in case of success, empty
%       array otherwise.
%
% $Date: November 1, 2019
% _________________________________________________________________________
function [gyroData] = lib_importNsrGyroFile(filePath)
    gyroData = [];
    
    try
        delimiter = ';';
        startRow = 4;
        formatSpec = '%f%f%f%f%[^\n\r]';

        % Open the text file.
        fileID = fopen(filePath,'r');
        
        if fileID ~= -1
            % Read columns of data according to the format.
            dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
            fclose(fileID);

            N = length(dataArray{1, 1});
            gyroData = repmat(GyroData,1,N);

            for i=1:1:N
                gyroData(i).valid = true;
                gyroData(i).ttag = floor(dataArray{1, 1}(i) / 1000);
                gyroData(i).omega_is = [dataArray{1, 2}(i), dataArray{1, 3}(i), dataArray{1, 4}(i)]';
            end
        end        
    catch
        fprintf('\n Exception caught while importing file %s !!!\n',filePath);
    end
end

