function [x_out] = lib_integrateInsOdeRkTwoDt(insOde,x_in,omega_is_1,omega_is_2,f_s_1,f_s_2,dt)
    % predict state using Heun's method
    f_1 = insOde(x_in,omega_is_1,f_s_1);
    x_tmp = x_in + dt * f_1;
    f_2 = insOde(x_tmp,omega_is_2,f_s_2);
    x_out = x_in + 0.5 * dt * (f_1 + f_2);
end

