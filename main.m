
% Generate 4 Base Stations %
b(1) = base_station(1, 61, [10, 10]);
b(2) = base_station(1, 61, [10, 20]);
b(3) = base_station(1, 61, [20, 20]);
b(4) = base_station(1, 61, [20, 10]);

% Seperate Coordinates %
x = []; y = [];
for k = 1:4
    x = [x, b(k).pos(1)];
    y = [y, b(k).pos(2)];
end

scatter(x,y)