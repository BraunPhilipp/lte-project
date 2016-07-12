% TODOS:
% 1)für die user_entities eigene draw funktions schreiben. cu.draw is noch
% relativ hässlich
% 2) DPS is zu 90% fertig aber erste version läuft
% 3) Backhaul calculation bei dps

clear
clf

% Generate coordinates of basestations
coordinates = helpers.calc_coordinates();
% Generate basestations according to the coordinats
[num_of_bs,~] = size(coordinates);
for i = 1:num_of_bs
    bs(i) = base_station(i, coordinates(i,:), 61, params.num_subcarrier, 2000000000, 1400000, params.num_subcarrier, randi([8,16]));
end

% Test coordinates
% scatter(coordinates(:,1)',coordinates(:,2)');

% Generate 32 Random Users
for i = 1:params.num_users
    ue(i) = user_entity(i, randi([0 params.space_size], 1, 2), -135, randi([1,4]));
end

% Initialize Central Unit
cu = central_unit(1,ue,bs);

% create TBS
TBS_obj = TBS('TBS.xls');

% testing:
% cu.map_users_cs();
% cu.conflict_list()
% for i = 1:length(bs)
%     cu.base_list(i).scheduling();
%     cu.base_list(i).modulation(TBS_obj.TBs);
%     cu.base_list(i).beamforming();
% end

% Simulate Transmission
for delta = 1:6
    %cu.map_users_dp();
    display('timestep');
    display(delta);
    cu.map_users_dps();
    for i = 1:length(bs)
        cu.base_list(i).scheduling();
        cu.base_list(i).modulation(TBS_obj.TBs);
        cu.base_list(i).beamforming();
    end
    cu.draw(delta);
end
