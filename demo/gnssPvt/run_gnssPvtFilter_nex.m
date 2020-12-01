clc;
clearvars;
clearvars global;

%%
addpath(genpath('..\..\lib'));
addpath(genpath('..\gnssLsq'));
addpath(genpath(pwd));

%%
nexFilename = '..\..\data\nsr\drive\20201121_152755_city\20201121_152755_GNSS_raw.nex';
nexMsg = importNexFile(nexFilename);

%% Create global objects
global gpsBcDB;
global gpsBcIonoParams;
global Ref;
global isNewEpoch;

gpsBcDB = repmat(GpsBcData,1,ConfGnssEng.MAX_SIGMEAS_NUM);
gpsBcIonoParams = DataGpsBcIonoParams;
Ref = {};

% Create measurement databases
gnssMeasDb = GnssMeasDb();
gnssPvtMeasDb = GnssPvtMeasDb();
isNewEpoch = false;

% Create least-squares filter. It is used to get the first fix.
gnssLsqFilter = GnssLsqFilter();

% Create PVT filer.
gnssPvtFilter = GnssPvtFilter();

arrayNavState = {};

%%
disp('Running navigation calculations...');
ttag = uint64(0);

activeFilter = 1; % 1 - lsq filter, 2 - pvt filter, we start with LSQ to get first fix
filterSet = false;

tic;
for i=1:1:length(nexMsg)
    % Check if filter is set, otherwise choose filter
    if ~filterSet
        if activeFilter == 1
            measDb = gnssMeasDb;
            filter = gnssLsqFilter;
            filterSet = true;
        elseif activeFilter == 2
            measDb = gnssPvtMeasDb;
            filter = gnssPvtFilter;
            % Add position fix from the LSQ filter as a measurement
            measDb = measDb.addData(stateNew,SensorType.NAV_STATE);
            filterSet = true;
        else
            % Something is wrong
            disp('Warning: wrong filter in use!');
        end
    end

    measDb = handleNexMsg(nexMsg{i},measDb);

    if isNewEpoch
        ttag = ttag + 1000000; % simulate ttag in [us]

        [filter, measDb] = lib_navFilterRoutine(filter, measDb, ttag);
        isNewEpoch = false;

        stateNew = NavState;

        if filter.getMode == FilterMode.RUNNING
            % we have a valid fix this epoch
            x = filter.getState();
            sMap = StateMapGnssPvt;
            stateNew.POS_x = x(sMap.POS_EX);
            stateNew.POS_y = x(sMap.POS_EY);
            stateNew.POS_z = x(sMap.POS_EZ);
            stateNew.CB = x(sMap.CB);
            stateNew.v_x = x(sMap.V_EX);
            stateNew.v_y = x(sMap.V_EY);
            stateNew.v_z = x(sMap.V_EZ);
            stateNew.CD = x(sMap.CD);
            constGps = getGpsConstants();
            [stateNew.gpsWn,stateNew.gpsTow] = addToGpsTime(0, 1e-9 * measDb.ttagRcv, stateNew.CB/constGps.c);
            stateNew.valid = true;              
            fprintf('TOW %f\n',stateNew.gpsTow);
        else
            if activeFilter == 2
                % PVT filter has stopped, we need to revert to LSQ to
                % get first fix again
                filterSet = false;
                activeFilter = 1;
            end
        end

        if activeFilter ~= 2 && stateNew.valid
            % We have got the first fix, start PVT filter
            filterSet = false;
            activeFilter = 2;
        end

        arrayNavState{end+1} = stateNew;
    end
end
toc;

disp('Processing finished.');

%%
disp('Evaluation started.');

lat = zeros(1,length(arrayNavState));
lon = zeros(1,length(arrayNavState));
height = zeros(1,length(arrayNavState));
time = zeros(1,length(arrayNavState));

for i=1:1:length(arrayNavState)
    if arrayNavState{i}.valid
        [lat(i), lon(i), height(i)] =...
            lib_ecefToLlh([arrayNavState{i}.POS_x; arrayNavState{i}.POS_y; arrayNavState{i}.POS_z], Wgs84);
        time(i) = arrayNavState{i}.gpsTow;
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

fprintf('Final coordnates: %3.15f, %3.15f  .\n', 180 / pi * lat(indOk(end)), 180 / pi * lon(indOk(end)));

figure;
subplot(3,1,1);
plot(time(indOk),v_e(1,indOk),'.-');
ylabel('Vel E x, [m/s]');

subplot(3,1,2);
plot(time(indOk),v_e(2,indOk),'.-');
ylabel('Vel E y, [m/s]');

subplot(3,1,3);
plot(time(indOk),v_e(3,indOk),'.-');
ylabel('Vel E z, [m/s]');
xlabel('GPS TOW, [s]');

figure;

subplot(2,1,1);
plot(time(indOk),CB(indOk),'.-');
ylabel('Clock bias, [m]');

subplot(2,1,2);
plot(time(indOk),CD(indOk),'.-');
ylabel('Clock drift, [m/s]');
xlabel('GPS TOW, [s]');

figure;
plot(180 / pi * lon(indOk), 180 / pi * lat(indOk),'x');
legend('GPS filtered solution');
xlabel('Longitude, [deg]');
ylabel('Latitude, [deg]');

disp('Evaluation finished.');