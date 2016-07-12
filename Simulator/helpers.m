classdef helpers
% Helpers makes generally used functions available to all files
% Especially necessary for more evolved models
methods (Static)

function dist = distance(pos1, pos2)
    % Returns Distance between two points
    dist = sqrt(sum((pos1-pos2).^2));
end

function n_of_bs = calc_n_of_bs()
    % calculate how many bs fit in a space of given size in hexagonal order
    % we calculate with hexagons of edge lenth 80
    n_of_bs = fix(params.space_size/138.5641)*fix(params.space_size/120);
end

function coordinates = calc_coordinates()
    coordinates = [];
    % values of hexagon:
    edge_length = params.edge_length;
    a=sin(pi/3)*edge_length;
    b=cos(pi/3)*edge_length;
    c=edge_length;
    hex = [];
    row =1;
    % initialize first hexagon:
    hex = [a,b+c/2];
    
    while (hex(2)<=params.space_size )
        % give hex its start value
        if mod(row,2)==1
            hex(1)=a;
        else
            hex(1)=2*a;
        end
        % add points to coordinats until end of space
        while (hex(1)<=params.space_size )
            coordinates = [coordinates; hex];
            hex(1) = hex(1) + 2*a;
        end
        % add 1 to row counter
        row = row +1;
        hex(2)= hex(2)+c+b;
    end
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
    s = helpers.friis(user, base(sel)) - (interference + user.noise);
end
    
end
end