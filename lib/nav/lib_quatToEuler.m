function [euler] = lib_quatToEuler(q)
    euler = zeros(3,1);
    % Roll
    euler(1) = atan2(2 * (q(3) * q(4) + q(1) * q(2)), 1 - 2 * (q(2) * q(2) + q(3) * q(3)));
    % Pitch
    euler(2) = -asin(2 * (q(2) * q(4) - q(1) * q(3)));
    % Heading
    euler(3) = atan2(2 * (q(2) * q(3) + q(1) * q(4)), 1 - 2 * (q(3) * q(3) + q(4) * q(4)));
end

