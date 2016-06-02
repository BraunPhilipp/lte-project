classdef central_unit
    %Central Unit to coordinate all base stations
    
    properties
        id; 
        base_list; %List of all coordinated stations
        user_list; %List of all users (not sure about it)
        %conflict_list; %List of all conflicts between base stations
    end
    
    methods
        function obj = central_unit(id_attr, user_attr, base_attr) %Creates a new central unit
            obj.id = id_attr;
            obj.user_list = user_attr;
            obj.base_list = base_attr;
            % obj.conflict_list = [];
        end
        
        function map_users(self)
            %adds users to user lists of basestation so that every base
            %station knows which users to serve
            for base_iter = self.base_list
                base_iter.user_list = [];
                for user_iter = self.user_list
                    %if power is high enough user is added to list
                    if (user_iter.receiving_pwr(base_iter) > 74)
                        base_iter.user_list = [base_iter.user_list user_iter];
                    end
                end
            end
        end
        
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