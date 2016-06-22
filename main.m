clear
clf
% Generate 4 Base Stations
for i = 1:params.num_basestations
    bs(i) = base_station(i, randi([0 300], 1, 2), 61, 8, 2000000000, 1400000, 8, randi([8,16]));
end

% Generate 32 Random Users
for i = 1:params.num_users
    ue(i) = user_entity(i, randi([0 300], 1, 2), -135, randi([1,4]));
end

% Initialize Central Unit
cu = central_unit(1,ue,bs);

% Simulate Transmission
for delta = 1:10
    cu.map_users();
    for i = 1:length(bs)
        cu.base_list(i).scheduling();
        cu.base_list(i).modulation(); % some error while choosing modulation
    end
end



% DRAW

% Display User Positions
% for user_iter = 1:length(ue)
%     x = ue(user_iter).pos(1);
%     y = ue(user_iter).pos(2);
%     plot(x,y,'-ob');
%     hold on;
% end
% 
% % Display Basestation Positions
% for base_iter = 1:length(bs)
%     x = bs(base_iter).pos(1);
%     y = bs(base_iter).pos(2);
%     plot(x,y,'-*r');
%     hold on;
% end
