classdef central_unit < handle
    % Central Unit to coordinate all Base Stations
    
    properties
        id; 
        base_list; % List of all Base Stations
        user_list; % List of all User Entities
        base_map;  % Map of connected Basestations
        user_map;  % Map of connected Users
    end
    
    methods
        function obj = central_unit(id_attr, user_attr, base_attr)
            % Constructor
            obj.id = id_attr;
            obj.user_list = user_attr;
            obj.base_list = base_attr;
            obj.base_map = [];
            obj.user_map = [];
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
        
        function conf_matr = conflict_list(self)
            % Find conflicting users on Cell Edges
            % ------------------------------------------------------------
            % Conflict List returns a Matrix of conflicting user entities
            % as well as a matrix. Enabling easier access lateron.
            
            conf_cell = cell(length(self.base_list),1);
            conf_matr = zeros(length(self.user_list));
            % Calculate Ranking Score
            snr_eval = self.ranking();
            % Find conflicting users based on location
            for user_iter1 = 1:length(self.user_list)
                for user_iter2 = 1:length(self.user_list)
                    if (user_iter1 ~= user_iter2 && helpers.distance(self.user_list(user_iter1).pos, ...
                                                self.user_list(user_iter2).pos) < params.user_distance)
                        % Same stations prefered ?
                        if ( sum(ismember(snr_eval(user_iter1,[1,2]),...
                                snr_eval(user_iter2,[1,2])))>1)
                            % Add Conflicting User to Matrix
                            conf_matr(user_iter1, user_iter2) = 1;
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
            
            % initialize map propert
            for user_iter = 1:length(self.user_list)
                self.user_list(user_iter).mapped = 0;
            end
            % Clear Lists for Simulation
            self.base_map = [];
            self.user_map = [];
            
            map = zeros(length(self.user_list),1);
            % Get the ranking: BS with highest SNR
            base_ranking = self.ranking();
            % Get list of conflicting users
            conf = self.conflict_list();
            ignore = [];
            for user_iter = 1:length(self.user_list)
                % Determine if a conflict exists for a specific user (user_iter)
                if (sum(conf(user_iter,:)) > 0)
                    % check which user conflicts have been solved
                    % check which user_iter is supposed to be ignored
                    found = sum(ismember(ignore, user_iter));
                    if (found == 0)
                        selected_user_conf = 0;
                        selected_user = 0;
                        Index = 0;
                        % Random Selection of a user from the group of
                        % conflicting users
                        while selected_user_conf == 0 ...
                                && selected_user ~= user_iter
                            selected_user = randi(length(conf(user_iter,:)));
                            selected_user_conf = conf(user_iter, selected_user);                             
                        end
                        % Ignore conflicting users so they wont get
                        % considered in the mapping precess anymore
                        for user_iter2 = 1:length(self.user_list)
                            if conf(user_iter, user_iter2) > 0 
                                ignore = [ignore user_iter2];
                            end
                        end
                        % Ignore user_iter if it is not mapped
                        if selected_user ~= user_iter
                            ignore = [ignore user_iter];
                        end
                        map(selected_user) = base_ranking(selected_user,1);
                        % save that user was mapped so we can find the
                        % unmapped easily later on
                        self.user_list(selected_user).mapped = 1;
                    end
                else
                    % Usual Matching
                    map(user_iter) = base_ranking(user_iter,1);
                    self.user_list(user_iter).mapped = 1;
                end
            end
            self.base_map = map;
            
            self.user_map = cell(length(self.base_list),1);
            for map_iter = 1:length(map)
                if map(map_iter) > 0
                    self.user_map{map(map_iter)} = [self.user_map{map(map_iter)}, map_iter];
                end
            end
            
            self.map_to_basestation();
            
            % Return map
            map;
        end
        
        function map_users_dp(self)
            % map defines to which basestation a user is mapped. For Example 
            % map(4)=3 means that user 4 is mapped to basestation 3.
            % continuously mutes signals of all other basestations
            
            % user served by basestation with best signal
            
            % Clear Lists for Simulation
            self.base_map = [];
            self.user_map = [];
            
            map = zeros(length(self.user_list),1);
            map = self.ranking();
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
        
        function draw(self,step)
            % draw all base stations and all users that are mapped to that 
            % base stations
            % Get list of conflicts:
            figure(step);
            conf = self.conflict_list();
            for base_iter = 1:length(self.base_list)
                for user_iter = 1:length(self.base_list(base_iter).user_list)   
                    x = self.base_list(base_iter).user_list(user_iter).pos(1);
                    y = self.base_list(base_iter).user_list(user_iter).pos(2);
                    if sum(conf(self.base_list(base_iter).user_list(user_iter).id,:))>0
                        plot(x,y,'-xm');
                        hold on;
                    else
                        plot(x,y,'-or');
                        hold on;
                    end
                    labels = cellstr(num2str(base_iter));
                    text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
                end
                x = self.base_list(base_iter).pos(1);
                y = self.base_list(base_iter).pos(2);
                plot(x,y,'-ob');
                labels = cellstr(num2str(base_iter));
                text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');
                hold on;
            end
            % Draw all unmapped users:
            for user_iter = 1:length(self.user_list)
                if self.user_list(user_iter).mapped ==0
                    x = self.user_list(user_iter).pos(1);
                    y = self.user_list(user_iter).pos(2);
                    if sum(conf(self.user_list(user_iter).id,:))>0
                        plot(x,y,'-xm');
                        hold on;
                    else
                        plot(x,y,'-or');
                        hold on;
                    end
                    labels = cellstr(num2str(0));
                    text(x,y,labels,'VerticalAlignment','bottom','HorizontalAlignment','right');                    
                end
            end
        end

    end
end
