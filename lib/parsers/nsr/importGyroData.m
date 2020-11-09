function [gyroData] = importGyroData(fileInfo)

    gyroData = [];
    %% Initialize variables.
    filename = strcat(fileInfo.folder,'\',fileInfo.name);
    delimiter = ';';
    startRow = 4;

    %% Format for each line of text:
    %   column1: double (%f)
    %	column2: double (%f)
    %   column3: double (%f)
    %	column4: double (%f)
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%f%f%f%f%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r');

    %% Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

    %% Close the text file.
    fclose(fileID);

    %% Post processing for unimportable data.
    % No unimportable data rules were applied during the import, so no post
    % processing code is included. To generate code which works for
    % unimportable data, select unimportable cells in a file and regenerate the
    % script.

    if size(dataArray,1) > 0
        gyroData = repmat(GyroData,1,size(dataArray{1,1},1));

        for i=1:1:length(gyroData)
            gyroData(i).valid = true;
            gyroData(i).ttag = uint64(0.001 * dataArray{1, 1}(i));
            gyroData(i).omega_is = [dataArray{1, 2}(i); dataArray{1, 3}(i); dataArray{1, 4}(i)];
        end
    end
end