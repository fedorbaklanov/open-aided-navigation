%% Clean-up
clear;
close all;

%% Configuration, may be changed by a user
% Select drive: short one or a long one.
drive = 'short'; % 'short' or 'long'
exitAfter = 100; % Percentage of the input file to be processed, set 50 to process only one half, [%]

%% Set path
addpath(genpath('..\..\lib'));

%% Data import
if strcmp(drive,'short')
    inputDir = '..\..\data\nsr\drive\20201104_093418';
else
    inputDir = '..\..\data\nsr\drive\20201104_091730';
end

[gyroData,accelData] = importImuData(inputDir);
gnssData = importGnssData(inputDir);

% Prepare to simulate event-based behavior
gyroTtags_us = uint64(zeros(1,length(gyroData)));
accelTtags_us = uint64(zeros(1,length(accelData)));
gnssTtags_us = uint64(zeros(1,length(gnssData)));

for i=1:1:length(gyroData)
    gyroTtags_us(i) = gyroData(i).ttag;
end

for i=1:1:length(accelData)
    accelTtags_us(i) = accelData(i).ttag;
end

for i=1:1:length(gnssData)
    gnssTtags_us(i) = gnssData(i).ttag;
end

allTtags_us = [gyroTtags_us, accelTtags_us, gnssTtags_us];
allEvents = [repmat(EventType.GYRO_DATA,1,length(gyroTtags_us)),...
             repmat(EventType.ACCEL_DATA,1,length(accelTtags_us)),...
             repmat(EventType.GNSS_DATA,1,length(gnssTtags_us))];
         
[allTtagSorted_us,ttagIndex] = sort(allTtags_us);

%% Create filter object and measurement database
insGnssFilter = InsGnssFilterLoose;
measDb = InsGnssLooseMeasDb(16);

%% Prepare arrays to store output
x_out = zeros(length(insGnssFilter.x),length(gyroTtags_us)); % preallocate an array for output states
p_out = zeros(length(insGnssFilter.dx),length(gyroTtags_us)); % preallocate an array for output variances
filMode_out = zeros(1,length(gyroTtags_us)); % preallocate an array for filter mode output

%% Start simulation
nextGyroInd = 1;
nextAccelInd = 1;
nextGnssInd = 1;
newEpoch = false;
progress = 0;

tic;
for i=1:1:length(ttagIndex)
    eventType = allEvents(ttagIndex(i));

    switch eventType
        case EventType.ACCEL_DATA
            measDb = measDb.addData(accelData(nextAccelInd),SensorType.ACCEL);
            nextAccelInd = nextAccelInd + 1;
        case EventType.GYRO_DATA
            measDb = measDb.addData(gyroData(nextGyroInd),SensorType.GYRO);
            nextGyroInd = nextGyroInd + 1;
            newEpoch = true;
        case EventType.GNSS_DATA
            measDb = measDb.addData(gnssData(nextGnssInd),SensorType.GNSS);
            nextGnssInd = nextGnssInd + 1;
        otherwise
            % do nothing
    end

    if newEpoch
        [insGnssFilter,measDb] = lib_navFilterRoutine(insGnssFilter,measDb,0);
        x_out(:,nextGyroInd-1) = insGnssFilter.x;
        p_out(:,nextGyroInd-1) = insGnssFilter.getVar();
        filMode_out(nextGyroInd-1) = insGnssFilter.getMode();
        newEpoch = false;
    end

    % Display progress
    progressNew = nextGyroInd/length(gyroTtags_us) * 100;
    if (progressNew - progress) > 0.5
        progress = progressNew;
        fprintf('Processed %3.2f%%\n',progress);
    end
    if progress >= exitAfter
        break;
    end
end
toc;

%% Do evaluation
mask = find(filMode_out == FilterMode.RUNNING);
time = 1e-6 * double(gyroTtags_us(mask) - gyroTtags_us(mask(1)));
sMap = StateMapInsGnssLoose;
esMap = ErrorStateMapInsGnssLoose;

x_e = x_out(sMap.POS_E,mask);
v_e = x_out(sMap.V_E,mask);
q_es = x_out(sMap.Q_ES,mask);
q_cs = x_out(sMap.Q_CS,mask);

[lat, lon, ~] = lib_ecefToLlh(x_e(:,1),Wgs84);
q_ne = lib_quatEcefToNed(lat,lon);
C_ne = lib_dcmEcefToNed(lat,lon);

q_ns = zeros(4,length(mask));
euler_ns = zeros(3,length(mask));
v_n = zeros(3,length(mask));
v_s = zeros(3,length(mask));
v_c = zeros(3,length(mask));
lat = zeros(1,length(mask));
lon = zeros(1,length(mask));
height = zeros(1,length(mask));
euler_mis = zeros(3,length(mask));

for i=1:1:length(mask)
    q_ns(:,i) = lib_quatMult(q_ne,q_es(:,i));
    euler_ns(:,i) = lib_quatToEuler(q_ns(:,i));
    v_n(:,i) = C_ne * v_e(:,i);
    C_es = lib_quatToDcm(q_es(:,i));
    v_s(:,i) = C_es' * v_e(:,i);
    [lat(i), lon(i), height(i)] = lib_ecefToLlh(x_e(:,i),Wgs84);
    euler_mis(:,i) = lib_quatToEuler(lib_quatMult(q_cs(:,i),[q_cs(1,1); -q_cs(2:4,1)]));
    v_c(:,i) = lib_quatToDcm(q_cs(:,i)) * v_s(:,i);
end

%% Plot lat-lon
figure;
plot(180 / pi * lon, 180 / pi * lat,'x');
ylabel('Latitude, [deg]');
xlabel('Longitude, [deg]');

%% Plot velocity NED
figure;
subplot(3,1,1);
plot(time,v_n(1,:));
title('Velocity in NED frame');
ylabel('v_n, [m/s]');
grid on;
subplot(3,1,2);
plot(time,v_n(2,:));
ylabel('v_e, [m/s]');
grid on;
subplot(3,1,3);
plot(time,v_n(3,:));
ylabel('v_d, [m/s]');
grid on;
xlabel('Time, [s]');

%% Plot velocity in car frame
figure;
subplot(3,1,1);
plot(time,v_c(1,:));
title('Velocity in car frame');
grid on;
ylabel('v_c_x, [m/s]');
subplot(3,1,2);
plot(time,v_c(2,:));
grid on;
ylabel('v_c_y, [m/s]');
subplot(3,1,3);
plot(time,v_c(3,:));
grid on;
ylabel('v_c_z, [m/s]');
xlabel('Time, [s]');

%% Plot IMU orientation
figure;
subplot(3,1,1);
plot(time, 180 / pi * euler_ns(1,:));
title('Euler angles, NED to IMU');
ylabel('Roll, [deg]');
grid on;
subplot(3,1,2);
plot(time, 180 / pi * euler_ns(2,:));
ylabel('Pitch, [deg]');
grid on;
subplot(3,1,3);
plot(time, 180 / pi * euler_ns(3,:));
ylabel('Yaw, [deg]');
grid on;
xlabel('Time, [s]');

%% Plot sensor offsets
figure;
labels = {'b_f_x, [m/s^2]','b_f_y, [m/s^2]','b_f_z, [m/s^2]',...
    'b_\omega_x, [rad/s]','b_\omega_y, [rad/s]','b_\omega_z, [rad/s]'};
stateRange = sMap.B_FX:sMap.B_WZ;
errorStateRange = esMap.B_FX:esMap.B_WZ;
for i=1:1:6
    subplot(6,1,i);
    plot(time,x_out(stateRange(i),mask));
    if i==1
        title('Estimated sensor biases');
    end
    hold on;
    plot(time,x_out(stateRange(i),mask) + 3 * sqrt(p_out(errorStateRange(i),mask)),'r');
    hold on;
    plot(time,x_out(stateRange(i),mask) - 3 * sqrt(p_out(errorStateRange(i),mask)),'r');
    if i==1
        legend('value','\pm 3 \sigma');
    end
    ylabel(labels{i});
end
xlabel('Time, [s]');

%% Plot sensor scale factors
figure;
labels = {'s_f_x','s_f_y','s_f_z','s_\omega_x','s_\omega_y','s_\omega_z'};
stateRange = sMap.S_FX:sMap.S_WZ;
errorStateRange = esMap.S_FX:esMap.S_WZ;
for i=1:1:6
    subplot(6,1,i);
    plot(time,x_out(stateRange(i),mask));
    if i==1
        title('Estimated scale factors');
    end
    hold on;
    plot(time,x_out(stateRange(i),mask) + 3 * sqrt(p_out(errorStateRange(i),mask)),'r');
    hold on;
    plot(time,x_out(stateRange(i),mask) - 3 * sqrt(p_out(errorStateRange(i),mask)),'r');
    if i==1
        legend('value','\pm 3 \sigma');
    end
    ylabel(labels{i});
end
xlabel('Time, [s]');

%% Plot estimated mounting misalignment
figure;

subplot(3,1,1);
plot(time,180 / pi * euler_mis(1,:));
title('Estimated IMU to car misalignment');
hold on;
plot(time,180 / pi * (euler_mis(1,:) + 3 * sqrt(p_out(esMap.PSI_CC1,mask))),'r');
hold on;
plot(time,180 / pi * (euler_mis(1,:) - 3 * sqrt(p_out(esMap.PSI_CC1,mask))),'r');
legend('value','\pm 3 \sigma');
ylabel('Roll, [deg]');
grid on;

subplot(3,1,2);
plot(time,180 / pi * euler_mis(2,:));
hold on;
plot(time,180 / pi * (euler_mis(2,:) + 3 * sqrt(p_out(esMap.PSI_CC2,mask))),'r');
hold on;
plot(time,180 / pi * (euler_mis(2,:) - 3 * sqrt(p_out(esMap.PSI_CC2,mask))),'r');
ylabel('Pitch, [deg]');
grid on;

subplot(3,1,3);
plot(time,180 / pi * euler_mis(3,:));
hold on;
plot(time,180 / pi * (euler_mis(3,:) + 3 * sqrt(p_out(esMap.PSI_CC3,mask))),'r');
hold on;
plot(time,180 / pi * (euler_mis(3,:) - 3 * sqrt(p_out(esMap.PSI_CC3,mask))),'r');
ylabel('Yaw, [deg]');
grid on;
xlabel('Time, [s]');
