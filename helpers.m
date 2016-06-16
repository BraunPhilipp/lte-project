classdef helpers
% Helpers makes generally used functions available to all files
% Especially necessary for more evolved models
methods (Static)

function dist = distance(pos1, pos2)
    % Returns Distance between two points
    dist = sqrt(sum((pos1-pos2).^2));
end

function fr = friis(user, base)
    % Returns Received Power using friis equation
    lambda = 300000000 / base.frq;
    fr = base.pwr + base.gain + 20 * log10(lambda/(4*pi*helpers.distance(user.pos, base.pos)));
end

function s = sinr(user, base, sel)
    % Returns Signal-To-Noise (SINR)
    % user = user entity related to basestation
    % base = list of basestations
    % sel = index of selected basestation
    interference = 0;
    for i = 1:length(base)
       interference = interference + helpers.friis(user, base(i));
    end
    interference = interference - helpers.friis(user, base(sel));
    s = helpers.friis(user, base(sel)) / (interference + user.noise);
end
    
end
end