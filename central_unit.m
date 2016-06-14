classdef central_unit < handle
    %Central Unit to coordinate all base stations
    
    properties
        id; 
        base_list; %List of all coordinated stations
        user_list; %List of all users 
        maps;       % saves which user is connected to which basestation 
                    % -> see function map_users for more information
        maps_given; % saves if a generated map was already given to the basestations
        %conflict_list; %List of all conflicts between base stations
    end
    
    methods
        function obj = central_unit(id_attr, user_attr, base_attr) %Creates a new central unit
            obj.id = id_attr;
            obj.user_list = user_attr;
            obj.base_list = base_attr;
            obj.maps_given = [0,0];     % 0,0 means map1 and map2 have not been given to the basestations
            % obj.conflict_list = [];
        end
        
        function base_ranking = highest_snr(self)
            % base_ranking saves the basestation with the highest and 
            % second highest snr for every user
            base_ranking = zeros(length(self.user_list),2);
            % Therefore we calculate snr for all four basesations
            snr = zeros(4,1);
            %find user -> basestation with highest snr:
            for user_iter = 1:length(self.user_list)
                for base_iter = 1:length(self.base_list)
                    snr(base_iter,1) = self.user_list(user_iter).snr(self.base_list,base_iter);
                end
                % save highest snr:
                [~,Index] = max(snr);
                base_ranking(user_iter,1)=Index;
                snr(Index)= - sum(snr'*snr);
                %save second highest snr
                [~,Index] = max(snr);
                base_ranking(user_iter,2)=Index;                
            end
            
            
%             %adds users to user lists of basestation so that every base
%             %station knows which users to serve
%             for base_iter = self.base_list
%                 base_iter.user_list = [];
%                 for user_iter = self.user_list
%                     %if power is high enough user is added to list
%                     if (user_iter.receiving_pwr(base_iter) > 74)
%                         base_iter.user_list = [base_iter.user_list user_iter];
%                     end
%                 end
%             end
        end
        
        function list_of_conf = list_of_conflicts(self)
            % calculate if two user entities are close to each other and on
            % cell edge and save in conflicting list:
            list_of_conf = zeros(length(self.user_list));
            % calculate the highest and second highest snr
            snr_eval = self.highest_snr();
            % decide which users are conflicting:
            for user_iter1 = 1:length(self.user_list)
                for user_iter2 = (user_iter1+1):length(self.user_list)
                    %close to each other ?
                    if self.dist_bet_ues(self.user_list(user_iter1),self.user_list(user_iter2)) < 50
                        % preffering the same stations ?
                        if (snr_eval(user_iter1,1)==snr_eval(user_iter2,1))&&(snr_eval(user_iter1,1)==snr_eval(user_iter2,1))||(snr_eval(user_iter1,2)==snr_eval(user_iter2,1))&&(snr_eval(user_iter1,1)==snr_eval(user_iter2,2))
                            list_of_conf(user_iter1,user_iter2)=1;
                            self.user_list(user_iter1)
                            self.user_list(user_iter2)
                        end
                    end
                end
            end
        end
        
        function dist = dist_bet_ues(~, ue1, ue2)
            % calculate dist between two user entities
            dist = sqrt((ue1.pos-ue2.pos)*(ue1.pos-ue2.pos)');
        end
        
        function map_users_CS(self)
            % map1 and map2 save which user is mapped to which
            % basestation. For Example map1(4)=3 means that user 4 is
            % mapped to bs 3. Map1 one is for the following time step (+T)
            % and map 2 is for the time step after that (+2T). Map(1) = 0
            % means that user 1 is not transmitted to.
            map1 = zeros(length(self.user_list),1);
            map2 = zeros(length(self.user_list),1);
            base_ranking = self.highest_snr();
            list_of_conf = self.list_of_conflicts();
            for user_iter = 1:length(self.user_list)
                % check if user is not mapped yet
                if (map1(user_iter)==0)&&(map2(user_iter)==0)
                    % check if there is a conflict
                    if (sum(list_of_conf(user_iter,:)~=0))
                        %CS
                        % get other ue which user_iter is conflicting with
                        [~,index]= max(list_of_conf(user_iter,:));
                        % map the ues in different time slots
                        map1(index)= base_ranking(index,1);
                        map2(user_iter)=base_ranking(user_iter,1);
                    else
                        % usual matching
                        map1(user_iter)= base_ranking(user_iter,1);
                        map2(user_iter)= base_ranking(user_iter,1);
                    end
                end
            end
            self.maps = [map1 map2];
            % give maps to base station
        end
        
        function  empty_user_lists(self)
            % empty the list of the users in every basestation
            for base_iter = 1:length(self.base_list)
                self.base_list(base_iter).user_list=[];
            end
        end
        
        
        function give_map_to_bs(self)
            % empty the userlists of all bases for the new timestep
            self.empty_user_lists();
            map_sel = 0;
            if self.maps_given(1)==0
                self.maps_given(1)=1;
                % give map1 to user
                map_sel =1;
            elseif self.maps_given(2) == 0
                self.maps_given(2)=1;
                % give map2 to user
                map_sel = 2;
            else
                % if both maps are given to the basestations generate new
                % maps
                self.map_users_CS();                
            end
            for user_iter = 1:length(self.user_list)
                if self.maps(user_iter, map_sel)~=0
                    self.base_list(map(user_iter)).base_list(end+1)=self.user_list(user_iter);
                end
            end
        end
        
        function simulate(self)
            self.give_map_to_bs();
            self.base_list.scheduling();
            self.base_list.get_modulation();
        end
        
        %COORDINATED SCHEDULING
        %conf = cell(n,n)
        %within each cell is an array of all the users
        %conf (2,1) =  [UE1, UE2, ...]
        
        %komische Funktion:
%         function stations = add_station(self,base)
%             %Adds station to the list
%             for i=1:length(base.user_list)
%                 %Checks whether users are already linked to a station
%                 trigger_confl=0;
%                 for j=1:length(self.user_list)
%                     if self.user_list(j).id == base.user_list(i).id
%                         trigger_confl=1;
%                         %if yes, they're added to a conflict list (what to
%                         %do with it is still to be implemented...)
%                         self.conflict_list = [self_conflict_list self.user_list(j)];
%                     end
%                 end
%                 if trigger_confl==0
%                     self.user_list = [self.user_list base.user_list(i)];
%                 end
%             end
%             self.station_list = [self.station_list base];
%             stations = self.station_list; %Add station
%         end      

            
    
    end       
    
end
