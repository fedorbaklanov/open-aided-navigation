function [traj] = simulateImuDataFromEcefPosAtt(sp_x_e,sp_euler_es,t0,t1,dt)
    traj.time = t0:dt:t1; % Generate target time grid
    N = length(traj.time);

    traj.x_e = fnval(sp_x_e,traj.time); % Derive reference position
    traj.v_e = fnval(fnder(sp_x_e,1),traj.time); % Derive reference velocity
    euler_es = fnval(sp_euler_es,traj.time); % Get Euler angles on target time grid

    % Preallocate some memory
    traj.q_es = zeros(4,N);
    traj.f_s = zeros(3,N);
    traj.omega_is = zeros(3,N);

    % Derive acceleration (velocity dot) and derivatives of Euler angles
    a_e = fnval(fnder(sp_x_e,2),traj.time);
    euler_es_dot = fnval(fnder(sp_euler_es,1),traj.time);

    % Inversion of navigation equations (ODEs that describe motion of a
    % point mass in the neighborhood of the Earth)
    for i=1:1:N
        traj.q_es(:,i) = lib_eulerToQuat(euler_es(1,i),euler_es(2,i),euler_es(3,i));
        C_es = lib_quatToDcm(traj.q_es(:,i));

        % Invert velocity differential equation to obtain specific force
        traj.f_s(:,i) = C_es' * (a_e(:,i) - lib_gravityEcefJ2(traj.x_e(:,i),Wgs84) + [-2 * Wgs84.omega_ie * traj.v_e(2,i);...
                                                                                      2 * Wgs84.omega_ie * traj.v_e(1,i);...
                                                                                      0]);

        % Invert differential equation for quaternion to obtain angular
        % rate
        q_es_dot = quatDotFromEuler(euler_es(1,i), euler_es_dot(1,i), euler_es(2,i), euler_es_dot(2,i), euler_es(3,i), euler_es_dot(3,i));
        q_omega_is = 2 * q_es_dot + [ -Wgs84.omega_ie * traj.q_es(4,i);...
                                      -Wgs84.omega_ie * traj.q_es(3,i);...
                                       Wgs84.omega_ie * traj.q_es(2,i);...
                                       traj.q_es(1,i) * Wgs84.omega_ie];
        q_omega_is = lib_quatMult([traj.q_es(1,i); -traj.q_es(2:4,i)], q_omega_is);
        traj.omega_is(:,i) = q_omega_is(2:4);
    end
end

