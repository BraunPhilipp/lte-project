
% Generate 4 Base Stations
b(1) = base_station(1, 61, [10, 10]);
b(2) = base_station(1, 61, [10, 20]);
b(3) = base_station(1, 61, [20, 20]);
b(4) = base_station(1, 61, [20, 10]);

% Generate 10 Random Users
for i = 1:10
    a(i) = user_entity(i, [randi([0 30], 1, 2)]);
end

a(1).distance(b(1))
% Total waste of time will try some other day