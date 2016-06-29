clear
clf

% Generate coordinates of basestations
coordinates = helpers.calc_coordinates();
% Generate basestations according to the coordinats
[~,num_of_bs] = size(coordinates);
for i = 1:num_of_bs
    bs(i) = base_station(i, coordinates(i,:), 61, params.num_subcarrier, 2000000000, 1400000, 8, randi([8,16]));
end

% Test coordinates
% scatter(coordinates(:,1)',coordinates(:,2)');

% Generate 32 Random Users
for i = 1:params.num_users
    ue(i) = user_entity(i, randi([0 300], 1, 2), -135, randi([1,4]));
end

% Initialize Central Unit
cu = central_unit(1,ue,bs);

% create TBS
TBS_obj = TBS('TBS.xls');

% Simulate Transmission
for delta = 1:5
    %cu.map_users_dp();
    cu.map_users_cs();
    for i = 1:length(bs)
        cu.base_list(i).scheduling();
        cu.base_list(i).modulation(TBS_obj.TBs);
        cu.base_list(i).beamforming();
    end
end

% Draw Basestation and User Positions
% for base_iter = 1:length(cu.base_list)
%     for user_iter = 1:length(cu.base_list(base_iter).user_list)   
%         x = cu.base_list(base_iter).user_list(user_iter).pos(1);
%         y = cu.base_list(base_iter).user_list(user_iter).pos(2);
%         if cu.base_list(base_iter).user_list(user_iter).conflict == 1
%             plot(x,y,'-xm');
%             hold on;
%         else
%             plot(x,y,'-or');
%             hold on;
%         end
%         labels = cellstr(num2str(base_iter));
%         text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
%     end
%     x = cu.base_list(base_iter).pos(1);
%     y = cu.base_list(base_iter).pos(2);
%     plot(x,y,'-ob');
%     labels = cellstr(num2str(base_iter));
%     text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
%     hold on;
% end
