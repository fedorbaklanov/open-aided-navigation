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
global gnssMeasDb;
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
    handleNexMsg(nexMsg{i});

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

[lat, lon, height] = lib_ecefToLlh([arrayNavState{end}.POS_x;...
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

indOk = find((lon ~= 0) & (lat ~= 0));

figure;
plot(180 / pi * lon(indOk), 180 / pi * lat(indOk),'x');
legend('GPS least-squares solution');
xlabel('Longitude, [deg]');
ylabel('Latitude, [deg]');

disp('Evaluation finished.');