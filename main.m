clear
% Generate 4 Base Stations
bs(1) = base_station(1, 43, [100, 100], 2000000000, 1400000, 8);
bs(2) = base_station(2, 43, [100, 200], 2000000000, 1400000, 6);
bs(3) = base_station(3, 43, [200, 200], 2000000000, 1400000, 10);
bs(4) = base_station(4, 43, [200, 100], 2000000000, 1400000, 5);

% Generate 10 Random Users
for i = 1:25
    ue(i) = user_entity(i, randi([0 300], 1, 2), -135);
end

cu = central_unit(1,ue,bs);
cu.list_of_conflicts()

%cu.base_list.user_list;

%cu.base_list(1).scheduling()
%cu.base_list(1).get_modulation()

%clear;
%ue(1).snr(bs, 2)
