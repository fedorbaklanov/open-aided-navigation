function [gnssData] = importGnssData(inputDir)
    gnssData = [];
    workDir = pwd;
    cd(inputDir);

    gnssFiles = dir('*_GNSS.csv');

    if size(gnssFiles,1) > 1
        disp('Multiple location data files fount in the input directory. Cannot import!');
    elseif size(gnssFiles,1) == 0
        disp('Necessary input file may be missing! Cannot import!');
    else        
        %% Setup the Import Options
        opts = delimitedTextImportOptions("NumVariables", 11);

        % Specify range and delimiter
        opts.DataLines = [2, Inf];
        opts.Delimiter = ";";

        % Specify column names and types
        opts.VariableNames = ["TimestampGNSSns", "UTCtimems", "Latdeg", "Londeg", "Heightm", "Speedms", "Headingdeg", "HorAccm", "VertAccm", "SpeedAccms", "HeadingAccdeg"];
        opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
        opts.ExtraColumnsRule = "ignore";
        opts.EmptyLineRule = "read";

        % Import the data
        tbl = readtable(strcat(gnssFiles.folder,'\',gnssFiles.name), opts);

        %% Convert to output type      
        len = size(tbl.TimestampGNSSns,1);
        
        if size(tbl.TimestampGNSSns,1) > 0
            gnssData = repmat(GnssNavData,1,len);

            for i=1:1:length(gnssData)
                gnssData(i).valid = true;
                gnssData(i).ttag = uint64(0.001 * tbl.TimestampGNSSns(i));
                gnssData(i).utcTime = uint64(tbl.UTCtimems(i));
                gnssData(i).lat = pi / 180 * tbl.Latdeg(i);
                gnssData(i).lon = pi / 180 * tbl.Londeg(i);
                gnssData(i).height = tbl.Heightm(i);
                gnssData(i).hAcc = tbl.HorAccm(i);
                gnssData(i).vAcc = tbl.VertAccm(i);
            end
        end
    end

    cd(workDir);
end

