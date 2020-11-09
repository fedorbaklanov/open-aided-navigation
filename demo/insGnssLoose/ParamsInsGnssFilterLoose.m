classdef ParamsInsGnssFilterLoose  
    properties (Constant)
        ROLL_IMU2CAR = -pi/2  % Roll angle: IMU to car frame rotation, [rad]
        PITCH_IMU2CAR = 0     % Pitch angle: IMU to car frame rotation, [rad]
        YAW_IMU2CAR = pi/2    % Yaw angle: IMU to car frame rotation, [rad]

        USE_NHC = true        % Enable/disable usage of NHC updates
        NHC_RATE_THRES = 0.03 % Turn rate threshold defining when not to use NHC updates, [rad]
        NHC_ACCEL_THRES = 0.2 % Acceleration threshold defining when not to use NHC updates, [m/s^2]

        GYRO_FREQ = uint8(50) % Configured gyroscope measurement frequency

        ATT_INIT_ACCEL_THRES = 0.5 % Maximum tolerable acceleration during INS alignment, [m/s^2]
        MIN_VEL_INIT_INTERVAL = 5  % Minimum time interval for velocity and heading initialization, [s]
        MAX_VEL_INIT_INTERVAL = 10 % Maximum time interval for velocity and heading initialization, [s]
        MIN_DPOS_VEL_INIT = 25     % Minimum position dispacement for derivation of velocity, [m]
    end
end
