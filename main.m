
% Generate 4 Base Stations
bs(1) = base_station(1, 43, [100, 100], 2000000000, 1400000, 8);
bs(2) = base_station(2, 43, [100, 200], 2000000000, 1400000, 6);
bs(3) = base_station(3, 43, [200, 200], 2000000000, 1400000, 10);
bs(4) = base_station(4, 43, [200, 100], 2000000000, 1400000, 5);

% Generate 10 Random Users
for i = 1:10
    ue(i) = user_entity(i, [randi([0 300], 1, 2)], -135);
end

% ue(1).distance(b(1))
% ue(1).friis(b(2))

ue(1).snr(bs, 2)

% Channel Testing
% ts = 100;
% fd = 0.001;

% what to do with rayleighchannel??
% chan = rayleighchan(ts,fd);
% x = [repmat(1:1000,1)];
% y = filter(chan,x);

% plot(y,x)


