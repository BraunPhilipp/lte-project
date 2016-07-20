classdef central_unit < handle
    % Central Unit to coordinate all Base Stations
    
    properties
        id; 
        base_list; % List of all Base Stations
        user_list; % List of all User Entities
        base_map;  % Map of connected Basestations
        user_map;  % Map of connected Users
        backhaul_list;
    end
    
    methods
        function obj = central_unit(id_attr, user_attr, base_attr)
            % Constructor
            obj.id = id_attr;
            obj.user_list = user_attr;
            obj.base_list = base_attr;
            obj.base_map = [];
            obj.user_map = [];
            obj.backhaul_list = cell(length(base_attr),1);
        end
        
        function ranking = ranking(self)
            % Ranking determines all possible parameters to find the best
            % basestation
            ranking = zeros(length(self.user_list),1);
            
            % Perform SINR Ranking
            sinr_ranking = [];
            for user_iter = 1:length(self.user_list)
                tmp_sinr = [];
                for base_iter = 1:length(self.base_list)
                    tmp_sinr(base_iter) = helpers.sinr(self.user_list(user_iter), ...
                                                            self.base_list, base_iter);
                end
                % save highest snr ranking list
                for base_iter = 1:length(tmp_sinr)
                    [~,Index] = max(tmp_sinr);
                    sinr_ranking(user_iter, base_iter) = Index;
                    tmp_sinr(Index) = -inf;
                end           
            end
            
            % Perform Distance Ranking
            dist_ranking = [];
            for user_iter = 1:length(self.user_list)
                tmp_dist = [];
                for base_iter = 1:length(self.base_list)
                    tmp_dist(base_iter) = - helpers.distance(self.user_list(user_iter).pos, ...
                                                             self.base_list(base_iter).pos);
                end
                % save highest dist ranking list
                for base_iter = 1:length(tmp_dist)
                    [~,Index] = max(tmp_dist);
                    dist_ranking(user_iter, base_iter) = Index;
                    tmp_dist(Index) = -inf;
                end
            end
            
            sinr_ranking;
            dist_ranking;
            
            % Possible Optimization Problem & Fallback Basestations
            
            % Return only best SINR basestations
            ranking = sinr_ranking(:,[1,2]);
        end
        
        function [conf_matr,conf_cell_user] = conflict_list(self)
            % Find conflicting users on Cell Edges
            % ------------------------------------------------------------
            % Conflict List returns a Matrix of conflicting user entities
            % as well as a matrix. Enabling easier access lateron.
            
            conf_cell = cell(length(self.base_list),1);
            conf_cell_user = cell(length(self.user_list),1);
            conf_matr = zeros(length(self.user_list));
            % Calculate Ranking Score
            snr_eval = self.ranking();
            % Find conflicting users based on location
            for user_iter1 = 1:length(self.user_list)
                for user_iter2 = 1:length(self.user_list)
                    if (user_iter1 ~= user_iter2 && helpers.distance(self.user_list(user_iter1).pos, ...
                                                self.user_list(user_iter2).pos) < params.user_distance)
                        % Same stations prefered ?
                        if ( snr_eval(user_iter1,1)==snr_eval(user_iter2,2)...
                                ||snr_eval(user_iter1,2)==snr_eval(user_iter2,1))
                            % Add Conflicting User to Matrix and Cell
                            conf_matr(user_iter1, user_iter2) = 1;
                            conf_cell_user{user_iter1} = [conf_cell_user{user_iter1} user_iter2];
                            % Check if user1 already in conflict list
                            if ( ~ismember(user_iter1, conf_cell{snr_eval(user_iter1),1}) )
                            	conf_cell{snr_eval(user_iter1),1} = [ conf_cell{snr_eval(user_iter1),1}, user_iter1 ];
                            end
                            % Check if user2 already in conflict list
                            if ( ~ismember(user_iter2, conf_cell{snr_eval(user_iter2),1}) )
                            	conf_cell{snr_eval(user_iter2),1} = [ conf_cell{snr_eval(user_iter2),1}, user_iter2 ];
                            end
                        end
                    end
                end
            end
            % Generates conflict cell array
            conf_cell;
            conf_matr;
        end
        
        function map_users_cs(self)
            % map defines to which basestation a user is mapped. For Example 
            % map(4)=3 means that user 4 is mapped to basestation 3.
            % continuously mutes signals of all other basestations
            
            % Clear Lists for Simulation
            self.base_map = [];
            self.user_map = [];
            
            for base_iter = 1:length(self.base_list)
                self.backhaul_list{base_iter}=[];
            end  
            
            map = zeros(length(self.user_list),1);
            % Get the ranking: BS with first and second highest SNR (n_users X 2)
            base_ranking = self.ranking();
            % Get matrix (n_users X n_users) of conflicting users
            [conf_matrix,conf_cell] = self.conflict_list();
            % List of users to be ignored in this mapping process
            ignore = [];
            for user_iter = 1:length(self.user_list)
                % Determine if a conflict exists for a specific user (user_iter)
                if (sum(conf_matrix(user_iter,:)) > 0)
                    % check if user_iter is supposed to be ignored
                    found = sum(ismember(user_iter, ignore));
                    if (found == 0)
                        % get group of conflicting_users:
                        conf_users = unique([user_iter conf_cell{user_iter}]);
                        % calculate which users are still allowed to be
                        % mapped
                        allowed_to_be_mapped = [];
                        % been mapped:
                        for conf_users_iter = 1:length(conf_users)
                            if sum(map(conf_cell{conf_users(conf_users_iter)})) ==0
                                allowed_to_be_mapped = [allowed_to_be_mapped conf_users(conf_users_iter)];
                            end
                        end
                        % map random users from the allowed_to_be_mapped list
                        if ~isempty(allowed_to_be_mapped)
                            selected_user_index = randi(length(allowed_to_be_mapped));
                            map(allowed_to_be_mapped(selected_user_index)) = ...
                                base_ranking(allowed_to_be_mapped(selected_user_index),1);
                            base = base_ranking(allowed_to_be_mapped(selected_user_index));
                            self.backhaul_list{base}=[self.backhaul_list{base} ...
                                allowed_to_be_mapped(selected_user_index)];
                            % Ignore conflicting users so they wont get
                            % considered in the mapping precess anymore
                            ignore =[ignore conf_users];
                        end                        
                    end
                    % user is to be ignored and is not mapped
                else
                    % Usual Matching
                    map(user_iter) = base_ranking(user_iter,1);
                     self.backhaul_list{base_ranking(user_iter,1)}=...
                         [self.backhaul_list{base_ranking(user_iter,1)} user_iter];
                end
            end
            self.base_map = map;
            
            self.user_map = cell(length(self.base_list),1);
            % user_map saves (in e.g. cell 3) which users are mapped to a
            % basestation (for example user_map(3)=[1,7,46])
            for map_iter = 1:length(map)
                if map(map_iter) > 0
                    self.user_map{map(map_iter)} = [self.user_map{map(map_iter)}, map_iter];
                end
            end
            
            self.map_to_basestation();
            
            % Return map
            map;
        end
        
        function map_users(self)
            for base_iter = 1:length(self.base_list)
                self.backhaul_list{base_iter}=[];
            end  
            % Clear Lists for Simulation
            self.base_map = [];
            self.user_map = [];
            % initialize map
            map = zeros(length(self.user_list),1);
            % Get the ranking: BS with first and second highest SNR (n_users X 2)
            base_ranking = self.ranking();
            map = base_ranking(:,1);
            for user_iter = 1:length(self.user_list)
                self.backhaul_list{base_ranking(user_iter,1)}=...
                        [self.backhaul_list{base_ranking(user_iter,1)} user_iter]
            end
            self.base_map = map;
            self.user_map = cell(length(self.base_list),1);
            for map_iter = 1:length(map)
                if map(map_iter) > 0
                    self.user_map{map(map_iter)} = [self.user_map{map(map_iter)}, map_iter];
                end
            end
            
            self.map_to_basestation();
            
        end
        
        function map_users_dps(self)
            % Dynamic Point Selection
            % map defines to which basestation a user is mapped. For Example 
            % map(4)=3 means that user 4 is mapped to basestation 3.
            % continuously mutes signals of all other basestations
            % initialize backhaul cell: saves which user to consider calculating backhaul:
            % backhaul_list{1} contains the users to consider for bs 1
            for base_iter = 1:length(self.base_list)
                self.backhaul_list{base_iter}=[];
            end                      
            
            % Clear Lists for Simulation
            self.base_map = [];
            self.user_map = [];
            % initialize map
            map = zeros(length(self.user_list),1);
            % Get the ranking: BS with first and second highest SNR (n_users X 2)
            base_ranking = self.ranking();
            % Get matrix (n_users X n_users) of conflicting users
            [conf_matrix,conf_cell] = self.conflict_list();
            for user_iter = 1:length(self.user_list)
                if sum(conf_matrix(user_iter,:)) > 0
                    % check if user is already mapped
                    if map(user_iter)==0
                        % get group of conflicting users:
                        conf_group = unique([user_iter conf_cell{user_iter}]);
                        % check if no member of conf_group is already mapped
                        if sum(map(conf_group))==0
                            % get list of possible basestations:
                            poss_bs = base_ranking(conf_group,1);
                            % select one randomly
                            selected_bs_index = randi(length(poss_bs));
                            % assign all users to that basestation:
                            map(conf_group)=poss_bs(selected_bs_index);
                            % add users to backhaul list:
                            for bs_iter = 1:length(poss_bs)
                                self.backhaul_list{poss_bs(bs_iter)}=...
                                    [self.backhaul_list{poss_bs(bs_iter)} conf_group];      
                            end
                        % check if one user of conf_group is already mapped
                        elseif sum(map(conf_group)>0)<2
                            [base_station,index] = max(map(conf_group));
                            user_index = conf_group(index);
                            for conf_group_iter = 1:length(conf_group)
                                map(conf_group(conf_group_iter))=base_station;
                            end
                        end
                    end                    
                else
                    % usual mapping:
                    map(user_iter)= base_ranking(user_iter,1);
                    self.backhaul_list{base_ranking(user_iter,1)}=...
                        [self.backhaul_list{base_ranking(user_iter,1)} user_iter]
                end
            end
            
            
            
%             map = self.ranking();
            self.base_map = map;
            
            self.user_map = cell(length(self.base_list),1);
            for map_iter = 1:length(map)
                if map(map_iter) > 0
                    self.user_map{map(map_iter)} = [self.user_map{map(map_iter)}, map_iter];
                end
            end
            
            self.map_to_basestation();
        end
        
        function map_to_basestation(self)
            % Pass User Entities to Basestation
            for base_iter = 1:length(self.base_list)
                self.base_list(base_iter).user_list = self.user_list(self.user_map{base_iter});
            end
        end
        
        function bhaul_tot = calc_TBS(self,TBS_of_ues)
            backhaul = zeros(length(self.base_list),1);
            for base_iter = 1:length(self.base_list)
                backhaul(base_iter)= sum(TBS_of_ues(self.backhaul_list{base_iter}));
                fprintf('Backhaul of BS %i: %f\n',base_iter, backhaul(base_iter));
            end
            bhaul_tot = sum(backhaul);
        end
        
        function draw(self,step)
            % draw all base stations and all users that are mapped to that 
            % base stations
            % Get list of conflicts:
            figure(step);
            clf;
            [conf,~] = self.conflict_list();
            cmap= lines(length(self.base_list));
            Conf_color= [1 0 1];
            for base_iter = 1:length(self.base_list)
                for user_iter = 1:length(self.base_list(base_iter).user_list)   
                    x = self.base_list(base_iter).user_list(user_iter).pos(1);
                    y = self.base_list(base_iter).user_list(user_iter).pos(2);
                    if sum(conf(self.base_list(base_iter).user_list(user_iter).id,:))>0
%                        plot(x,y,'.','color',cmap(base_iter,:),'MarkerSize',20);

                         plot(x,y,'*','color',cmap(base_iter,:),'MarkerSize',6);
                        hold on;
                    else
                        plot(x,y,'.','color',cmap(base_iter,:),'MarkerSize',20);
                        hold on;
                    end
                    labels = cellstr(num2str(base_iter));
%                     text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
                end
                x = self.base_list(base_iter).pos(1);
                y = self.base_list(base_iter).pos(2);
                plot(x,y,'^','color',cmap(base_iter,:),'MarkerSize',12);
                labels = cellstr(num2str(base_iter));
%                 text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
                hold on;
            end
            % Draw all unmapped users:
            
            for user_iter = 1:length(self.user_list)
                if self.base_map(user_iter) ==0
                    x = self.user_list(user_iter).pos(1);
                    y = self.user_list(user_iter).pos(2);
                    if sum(conf(self.user_list(user_iter).id,:))>0
                         plot(x,y,'*k','MarkerSize',6);
%                        plot(x,y,'.k','MarkerSize',20)

                        hold on;
                    else
                        plot(x,y,'.k','MarkerSize',20)
                        hold on;
                    end
                    labels = cellstr(num2str(0));
%                     text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');                    
                end
            end
        end
%             % draw all base stations and all users that are mapped to that 
%             % base stations
%             % Get list of conflicts:
%             
%             figure(step);
%             clf;
%             hold on;
%             
%             [conf,~] = self.conflict_list();
%             cmap= lines(length(self.base_list));
%             Conf_color= [1 0 1];
%             for base_iter = 1:length(self.base_list)
%                 for user_iter = 1:length(self.base_list(base_iter).user_list)   
%                     x = self.base_list(base_iter).user_list(user_iter).pos(1);
%                     y = self.base_list(base_iter).user_list(user_iter).pos(2);
%                     if sum(conf(self.base_list(base_iter).user_list(user_iter).id,:))>0
%                         conf_user_plot = plot(x,y,'mx');
%                         
%                     else
%                         user_plot = plot(x,y,'ro');
%                         
%                     end
%                     labels = cellstr(num2str(base_iter));
%                     text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
%                 end
%                 x = self.base_list(base_iter).pos(1);
%                 y = self.base_list(base_iter).pos(2);
%                 bs_plot = plot(x,y,'bo');
%                 labels = cellstr(num2str(base_iter));
%                 text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
%                 
%             end
%             % Draw all unmapped users:
%             for user_iter = 1:length(self.user_list)
%                 if self.base_map(user_iter) ==0
%                     x = self.user_list(user_iter).pos(1);
%                     y = self.user_list(user_iter).pos(2);
%                     if sum(conf(self.user_list(user_iter).id,:))>0
%                         plot(x,y,'mx');
%                     
%                     else
%                         plot(x,y,'ro');
%                         
%                     end
%                     labels = cellstr(num2str(0));
%                     text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');                    
%                 end
%             end
%             hold off;
%             legend([user_plot,bs_plot,conf_user_plot],{...
%                 'users','basestations','conflicting users'})
%         end

    end
end
