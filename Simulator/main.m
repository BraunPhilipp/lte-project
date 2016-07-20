%% Initialization
clear
clf

% Generate coordinates of basestations
coordinates = helpers.calc_coordinates();
% Generate basestations according to the coordinats
[num_of_bs,~] = size(coordinates);
for i = 1:num_of_bs
    bs(i) = base_station(i, coordinates(i,:), 61, params.num_subcarrier, 2000000000, 1400000, params.num_subcarrier, randi([8,16]));
end

% %% Generate SINR Profile
% sinr_profile = [];
% for x = -1000:50:1000
% for y = -1000:50:1000
%     % Calculate profile of all possible sending basestations
%     user = user_entity(i, [x y], -135, randi([1,4]));
%     z = 0;
%     for base_iter = 1:length(bs)
%         z = z + helpers.sinr(user, bs, base_iter);
%     end
%     sinr_profile = [sinr_profile; [x y z]];
% end
% end
% 
% tri = delaunay(sinr_profile(:,1), sinr_profile(:,2));
% trisurf(tri,sinr_profile(:,1), sinr_profile(:,2), sinr_profile(:,3))
% 
% %sinr_profile

% % Test coordinates
% % scatter(coordinates(:,1)',coordinates(:,2)');
% 
% Generate 32 Random Users
for i = 1:params.num_users
    ue(i) = user_entity(i, randi([0 params.space_size], 1, 2), -135, randi([1,4]));
end

% Initialize Central Unit
cu = central_unit(1,ue,bs);

% Create TBS
TBS_obj = TBS('TBS.xls');

% %% Throughput Calculation
% % Dynamic Point Selection
% 
% x_values = [];
% 
% for j = 1:1000
%     % Generate coordinates of basestations
%     coordinates = helpers.calc_coordinates();
%     % Generate basestations according to the coordinats
%     [num_of_bs,~] = size(coordinates);
%     for i = 1:num_of_bs
%         bs(i) = base_station(i, coordinates(i,:), 61, params.num_subcarrier, 2000000000, 1400000, params.num_subcarrier, randi([8,16]));
%     end
%     
%     % Generate 32 Random Users
%     for i = 1:params.num_users
%         ue(i) = user_entity(i, randi([0 params.space_size], 1, 2), -135, randi([1,4]));
%     end
% 
%     % Initialize Central Unit
%     cu = central_unit(1,ue,bs);
% 
%     % Create TBS
%     TBS_obj = TBS('TBS.xls');
%     
%     cu.map_users_dps();
% 
%     thrput = 0.0;
%     for i = 1:length(bs)
%         cu.base_list(i).scheduling();
%         cu.base_list(i).modulation(TBS_obj.TBs);
%         cu.base_list(i).beamforming();
%         thrput = thrput + cu.base_list(i).bhaul;
%     end
% 
%     dps_thrput = thrput;
%     x_values = [x_values thrput];
%     %cu.draw(1);
%     j
% end

% for j = 1:1000
%     % Generate coordinates of basestations
%     coordinates = helpers.calc_coordinates();
%     % Generate basestations according to the coordinats
%     [num_of_bs,~] = size(coordinates);
%     for i = 1:num_of_bs
%         bs(i) = base_station(i, coordinates(i,:), 61, params.num_subcarrier, 2000000000, 1400000, params.num_subcarrier, randi([8,16]));
%     end
%     
%     % Generate 32 Random Users
%     for i = 1:params.num_users
%         ue(i) = user_entity(i, randi([0 params.space_size], 1, 2), -135, randi([1,4]));
%     end
% 
%     % Initialize Central Unit
%     cu = central_unit(1,ue,bs);
% 
%     % Create TBS
%     TBS_obj = TBS('TBS.xls');
%     
%     % Coordinated Scheduling
%     cu.map_users_cs();
% 
%     thrput = 0.0;
%     for i = 1:length(bs)
%         cu.base_list(i).scheduling();
%         cu.base_list(i).modulation(TBS_obj.TBs);
%         cu.base_list(i).beamforming();
%         thrput = thrput + cu.base_list(i).bhaul;
%     end
% 
%     cs_thrput = thrput;
%     %cu.draw(2);
%     x_values = [x_values thrput];
%     j
% end

%cs_thrput
%dps_thrput

%histfit(x_values);


%% Simulate Transmission
% for delta = 1:20
%     display('timestep');
%     display(delta);
%     %cu.map_users_dps();
%     cu.map_users_cs();
%     for i = 1:length(bs)
%         cu.base_list(i).scheduling();
%         cu.base_list(i).modulation(TBS_obj.TBs);
%         cu.base_list(i).beamforming();
%     end
%     cu.draw(1);
% end

ch = channel();
ch.ray_chan();

