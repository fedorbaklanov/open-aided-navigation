function [x_out] = propInsGnssLooseRkTwoDt(x_in,sMap,omega_is_1,omega_is_2,f_s_1,f_s_2,dt)
    b_omega = x_in(sMap.B_W);
    s_omega = x_in(sMap.S_W);
    b_f =  x_in(sMap.B_F);
    s_f = x_in(sMap.S_F);

    % compensate IMU data
    omega_is_1 = (s_omega .* omega_is_1) + b_omega;
    f_s_1 = (s_f .* f_s_1) + b_f;
    omega_is_2 = (s_omega .* omega_is_2) + b_omega;
    f_s_2 = (s_f .* f_s_2) + b_f;

    % predict state using Heun's method
    f_1 = insGnssLooseOde(x_in,sMap,omega_is_1,f_s_1);
    x_tmp = x_in + dt * f_1;
    f_2 = insGnssLooseOde(x_tmp,sMap,omega_is_2,f_s_2);
    x_out = x_in + 0.5 * dt * (f_1 + f_2);
end

