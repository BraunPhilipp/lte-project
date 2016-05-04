
% Generate 4 basestations %
for k = 1:5
   a(k) = base_station;
   a(k).position = [k*10 10];
end

% Seperate Coordinates %
x = []; y = [];
for k = 1:5
    x = [x, a(k).position(1)];
    y = [y, a(k).position(2)];
end

scatter(x,y)