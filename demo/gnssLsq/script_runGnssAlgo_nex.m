clc;
clearvars;
clearvars global;

%%
addpath(genpath('..\..\lib'));
addpath(genpath(pwd));

%%
nexFilename = '..\..\data\nsr\20200805_193534\20200805_193534_GNSS_raw.nex';
nexMsg = importNexFile(nexFilename);

%% Create global objects
global gpsBcDB;
global gpsBcIonoParams;
global Ref;
global isNewEpoch;

gnssMeasDb = GnssMeasDb();
gpsBcDB = repmat(GpsBcData,1,ConfGnssEng.MAX_SIGMEAS_NUM);
gpsBcIonoParams = DataGpsBcIonoParams;
Ref = {};
isNewEpoch = false;

gnssLsqFilter = GnssLsqFilter();
arrayNavState = {};

%%
disp('Running navigation calculations...');
ttag = uint64(0);

tic;
for i=1:1:length(nexMsg)
    gnssMeasDb = handleNexMsg(nexMsg{i},gnssMeasDb);

    if isNewEpoch
        ttag = ttag + 1000000; % simulate ttag in [us]
        [gnssLsqFilter, gnssMeasDb] = lib_navFilterRoutine(gnssLsqFilter, gnssMeasDb, ttag);
        isNewEpoch = false;

        stateNew = NavState;

        if gnssLsqFilter.getMode == FilterMode.RUNNING
            % we have a valid fix this epoch
            x = gnssLsqFilter.getState();
            stateNew.POS_x = x(1);
            stateNew.POS_y = x(2);
            stateNew.POS_z = x(3);
            stateNew.CB = x(4);
            stateNew.v_x = x(5);
            stateNew.v_y = x(6);
            stateNew.v_z = x(7);
            stateNew.CD = x(8);
            constGps = getGpsConstants();
            [stateNew.gpsWn,stateNew.gpsTow] = addToGpsTime(0, 1e-9 * gnssMeasDb.ttagRcv, stateNew.CB/constGps.c);
            stateNew.valid = true;              
            fprintf('TOW %f\n',stateNew.gpsTow);
        end

        arrayNavState{end+1} = stateNew;
    end
end
toc;

disp('Processing finished.');

%%
disp('Evaluation started.');

[lat, lon, ~] = lib_ecefToLlh([arrayNavState{end}.POS_x;...
                                    arrayNavState{end}.POS_y;...
                                    arrayNavState{end}.POS_z], Wgs84);

lat_deg = lat * 180 / pi;
lon_deg = lon * 180 / pi;

fprintf('Final coordnates: %3.15f, %3.15f  .\n', lat_deg, lon_deg);

lat = zeros(1,length(arrayNavState));
lon = zeros(1,length(arrayNavState));
height = zeros(1,length(arrayNavState));

for i=1:1:length(arrayNavState)
    if arrayNavState{i}.valid
        [lat(i), lon(i), height(i)] =...
            lib_ecefToLlh([arrayNavState{i}.POS_x; arrayNavState{i}.POS_y; arrayNavState{i}.POS_z], Wgs84);
    end
end

v_e = zeros(3,length(arrayNavState));
CB = zeros(1,length(arrayNavState));
CD = zeros(1,length(arrayNavState));

for i=1:1:length(arrayNavState)
    v_e(1,i) = arrayNavState{i}.v_x;
    v_e(2,i) = arrayNavState{i}.v_y;
    v_e(3,i) = arrayNavState{i}.v_z;
    CB(i) = arrayNavState{i}.CB;
    CD(i) = arrayNavState{i}.CD;
end

indOk = find((lon ~= 0) & (lat ~= 0));

figure;
subplot(3,1,1);
plot(v_e(1,indOk));
ylabel('Vel E x, [m/s]');

subplot(3,1,2);
plot(v_e(2,indOk));
ylabel('Vel E y, [m/s]');

subplot(3,1,3);
plot(v_e(3,indOk));
ylabel('Vel E z, [m/s]');

figure;

subplot(2,1,1);
plot(CB(indOk));
ylabel('Clock bias, [m]');

subplot(2,1,2);
plot(CD(indOk));
ylabel('Clock drift, [m/s]');

figure;
plot(180 / pi * lon(indOk), 180 / pi * lat(indOk),'x');
legend('GPS least-squares solution');
xlabel('Longitude, [deg]');
ylabel('Latitude, [deg]');

disp('Evaluation finished.');