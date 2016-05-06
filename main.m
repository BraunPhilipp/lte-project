
% Generate 4 Base Stations
b(1) = base_station(1, 61, [100, 100], 2000000000, 1400000, 8);
b(2) = base_station(1, 61, [100, 200], 2000000000, 1400000, 6);
b(3) = base_station(1, 61, [200, 200], 2000000000, 1400000, 10);
b(4) = base_station(1, 61, [200, 100], 2000000000, 1400000, 5);

% Generate 10 Random Users
for i = 1:10
    a(i) = user_entity(i, [randi([0 300], 1, 2)]);
end


% a(1).distance(b(1))
% a(1).friis(b(2))
a(1).snr(b, 2)