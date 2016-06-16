clear
% Generate 4 Base Stations
for i = 1:parameter_file.n_basestations(parameter_file.num_simul)
    bs(i) = base_station(i, 43, randi([0 300], 1, 2), 2000000000,25, 1400000, 8);
end
% bs(1) = base_station(1, 43, [100, 100], 2000000000,25, 1400000, 8);
% bs(2) = base_station(2, 43, [100, 200], 2000000000,25, 1400000, 6);
% bs(3) = base_station(3, 43, [200, 200], 2000000000,25, 1400000, 10);
% bs(4) = base_station(4, 43, [200, 100], 2000000000,25, 1400000, 5);

% Generate 32 Random Users
for i = 1:parameter_file.n_users(parameter_file.num_simul)
    ue(i) = user_entity(i, randi([0 300], 1, 2), -135);
end

% initialize central unit
cu = central_unit(1,ue,bs);

% Simulate Transmission
cu.simulate();

%cu.base_list.user_list;

%cu.base_list(1).scheduling()
%cu.base_list(1).get_modulation()

%clear;
%ue(1).snr(bs, 2)
