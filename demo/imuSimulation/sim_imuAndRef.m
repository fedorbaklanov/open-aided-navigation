%% Clean-up
close all
clear variables

%% Configuration

targetImuFreq = 100; % Target frequency of IMU data, [Hz]
splineOrder = 6; % Order of the splines for trajectory and orientation interpolation.
startMask = 1; % Index of the trajectory and orientation data to start from, samples from 1 to startMask-1 will be skipped.
inputDataStep = 100; % Parameter for downsampling measured trajectory and orientation. Each inputDataStep-th measured point will be used, other masurements are ignored.

%% Run IMU data simulation

addpath(genpath('..\..\lib'));

% Load output of the insGnssFilterLoose
load('Pos_att_test_drive.mat');

% Mask the beginning
time = time(startMask:end) - time(startMask);
x_e = x_e(:,startMask:end);
q_es = q_es(:,startMask:end);

% Convert quaternion to Euler angles
euler_es = zeros(3,length(q_es));
for i=1:1:length(euler_es)
    euler_es(:,i) = lib_quatToEuler(q_es(:,i));
end

% Get rid of 2 * pi jumps
euler_es = unwrap(euler_es,[],2);

dt_target = 1/targetImuFreq; % derive desired IMU delta time
ind = 1:inputDataStep:length(time); % downsample measured trajectory prior to spline interpolation

% Fit splines into measured trajectory and orientation.
disp('Interpolating trajectory and orientation...');
sp_x_e = spapi(splineOrder,time(ind),x_e(:,ind));
sp_euler_es = spapi(splineOrder,time(ind),euler_es(:,ind));
disp('Done...');

% Generate ideal IMU measurements and a reference trajectory. Beginning and
% the end of the splines are ignored.
disp('Generating ideal IMU measurements...');
traj = simulateImuDataFromEcefPosAtt(sp_x_e,sp_euler_es,time(ind(1)+splineOrder),time(ind(end)-splineOrder),dt_target);
disp('Done...');

%% Verify simulated data.
% Do numerical integration of the generated IMU measurements to reconstruct
% reference trajectory.
disp('Verifying generated data...');
N = length(traj.time);
ins_state = zeros(10,N);

ins_state(:,1) = [traj.x_e(:,1); traj.v_e(:,1); traj.q_es(:,1)];
for i=2:1:N
    dt = traj.time(i) - traj.time(i-1);
    ins_state(:,i) = lib_integrateInsOdeRkTwoDt(@lib_insOdeEcef,ins_state(:,i-1),...
                                                traj.omega_is(:,i-1),traj.omega_is(:,i),...
                                                traj.f_s(:,i-1),traj.f_s(:,i),dt);
    ins_state(7:10,i) = ins_state(7:10,i) / norm(ins_state(7:10,i));
end
disp('Done...');

%% Plot measured trajectory vs. spline interpolated
disp('Starting evaluation...');
x_e_sp = fnval(sp_x_e,traj.time);
euler_es_sp = fnval(sp_euler_es,traj.time);

figure;
ylabels = {'X, [m]','Y, [m]','Z, [m]'};
for i=1:1:3
    subplot(3,1,i);
    plot(time,x_e(i,:));
    hold on;
    plot(traj.time,x_e_sp(i,:));
    if i==1
        title('Position ECEF');
        legend('Measured','Interpolated');
    end
    ylabel(ylabels{i});
end
xlabel('Time, [s]');

figure;
ylabels = {'Roll, [rad]','Pitch, [rad]','Heading, [rad]'};
for i=1:1:3
    subplot(3,1,i);
    plot(time,euler_es(i,:));
    hold on;
    plot(traj.time,euler_es_sp(i,:));
    if i==1
        title('Orientation (sensor to ECEF)');
        legend('Measured','Interpolated');
    end
    ylabel(ylabels{i});
end
legend('Measured','Interpolated');
xlabel('Time, [s]');

%% Plot simulated IMU data
figure;
ylabels = {'f_s_1, [m/s^2]','f_s_2, [m/s^2]','f_s_3, [m/s^2]'};
for i=1:1:3
    subplot(3,1,i);
    plot(traj.time,traj.f_s(i,:));
    if i==1
        title('Simulated accelerometer data');
    end
    ylabel(ylabels{i});
end
xlabel('Time, [s]');

figure;
ylabels = {'\omega_i_s_1, [rad/s]','\omega_i_s_2, [rad/s]','\omega_i_s_3, [rad/s]'};
for i=1:1:3
    subplot(3,1,i);
    plot(traj.time,traj.omega_is(i,:));
    if i==1
        title('Simulated gyroscope data');
    end
    ylabel(ylabels{i});
end
xlabel('Time, [s]');

%% Plot deviation of the reconstructed trajectory from the simulated reference.
figure;
plot(traj.time, traj.x_e(1,:) - ins_state(1,:));
hold on;
plot(traj.time, traj.x_e(2,:) - ins_state(2,:));
hold on;
plot(traj.time, traj.x_e(3,:) - ins_state(3,:));
title('Position error ECEF, [m]');
legend('X','Y','Z');
xlabel('Time, [s]');

figure;
plot(traj.time, traj.v_e(1,:) - ins_state(4,:));
hold on;
plot(traj.time, traj.v_e(2,:) - ins_state(5,:));
hold on;
plot(traj.time, traj.v_e(3,:) - ins_state(6,:));
title('Velocity error ECEF, [m/s]');
legend('X','Y','Z');
xlabel('Time, [s]');

psi_ee = zeros(3,N);

for i=1:1:N
    q_ee = lib_quatMult(traj.q_es(:,i), [ins_state(7,i); -ins_state(8:10,i)]);
    psi_ee(:,i) = lib_quatToEuler(q_ee);
end

figure;
plot(traj.time, psi_ee);
title('Orientation error, [rad]');
legend('\psi_e_e_1','\psi_e_e_2','\psi_e_e_3');
xlabel('Time, [s]');

%%
disp('Done...');
disp('Script finished successfully!');