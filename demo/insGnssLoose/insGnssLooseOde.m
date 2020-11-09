function [x_dot] = insGnssLooseOde(x,sMap,omega_is,f_s)
    x_dot = zeros(sMap.LEN,1);
    
    C_es = lib_quatToDcm(x(sMap.Q_ES));

    % Derivative of position
    x_dot(sMap.POS_E) = x(sMap.V_E);

    %Derivative of velocity
    x_dot(sMap.V_E) = lib_gravityEcefJ2(x(sMap.POS_E),Wgs84);
    x_dot(sMap.V_E) = x_dot(sMap.V_E) + C_es * f_s;
    x_dot(sMap.V_E) = x_dot(sMap.V_E) + [2 * Wgs84.omega_ie * x(sMap.V_EY); -2 * Wgs84.omega_ie * x(sMap.V_EX); 0];

    % Derivative of quaternion
    x_dot(sMap.Q_ES) = lib_quatMult(x(sMap.Q_ES), [0; omega_is]);
    x_dot(sMap.Q_ES) = x_dot(sMap.Q_ES) - [ -Wgs84.omega_ie * x(sMap.Q_ES3);...
                                            -Wgs84.omega_ie * x(sMap.Q_ES2);...
                                            Wgs84.omega_ie * x(sMap.Q_ES1);...
                                            x(sMap.Q_ES0) * Wgs84.omega_ie];
    x_dot(sMap.Q_ES) = 0.5 * x_dot(sMap.Q_ES);
end
