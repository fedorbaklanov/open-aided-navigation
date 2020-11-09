function [gyroData,accelData] = importImuData(inputDir)
    gyroData = [];
    accelData = [];
    workDir = pwd;
    cd(inputDir);

    accelFiles = dir('*_Acc.csv');
    gyroFiles = dir('*_Gyro.csv');

    if size(accelFiles,1) > 1 || size(gyroFiles,1) > 1
        disp('Multiple accelerometer and gyroscope data files fount in the input directory. Cannot import!');
    elseif size(accelFiles,1) == 0 || size(gyroFiles,1) == 0
        disp('Necessary input files may be missing! Cannot import!');
    else
        gyroData = importGyroData(gyroFiles);
        accelData = importAccelData(accelFiles);
    end

    cd(workDir);
end

