classdef base_station < handle
    % Base Station
    properties
        id;
        pos; % m [x y]
        pwr; % dBm
        gain;
        
        frq; % Hz
        bndw; % Hz
        
        user_list;
        
        subcarr_num;
        antenna_num;
        
        schd;
        modu;
        beam;
        steer;
        
        c_max;
        tbs_max;
        
        bhaul;
    end
   
    methods
        function obj = base_station(id_attr, pos_attr, pwr_attr, gain_attr, ...
                                            frq_attr, bndw_attr, subc_attr, antn_attr)
            % Constructor
            obj.id = id_attr;
            obj.pos = pos_attr;
            obj.pwr = pwr_attr;
            obj.gain = gain_attr;
            
            obj.frq = frq_attr;
            obj.bndw = bndw_attr;
            
            obj.user_list = [];
            
            obj.subcarr_num = subc_attr;
            obj.antenna_num = antn_attr;
            
            obj.schd = [];
            obj.modu = [];
            obj.beam = [];
            obj.steer = [];
            
            obj.c_max = [];
            obj.tbs_max = [];
            obj.bhaul = params.bhaul;
        end
        
        function beam = beamforming(self)
            if (~isempty(self.user_list))
                schd = zeros(length(self.schd),1);
                for schd_iter = 1:length(self.schd)
                    % count previous occurences
                    num_occ = sum(self.schd(schd_iter) == self.schd(1:schd_iter)) - 1;
                    schd(schd_iter) = num_occ;
                    % calculate antenna offset
                    theta = atan(num_occ / helpers.distance(self.user_list( ...
                                    self.schd(schd_iter)).pos, self.pos));
                    % steering vector            
                    self.steer = exp(-schd*i*theta);
                end
                % Output Phaseshift
                fprintf('Phase Shift: ');
                fprintf('%i ', schd);
                fprintf('\n');
                
                self.schd = schd;
            end
        end
        
        function sch = scheduling(self)
            fprintf('> Basestation: %i\n', self.id);
            % Coordinates scheduling activities (mere RoundRobin so far)
            if (~isempty(self.user_list))
                % Generate empty Signals for all users
                sch = zeros(length(self.user_list), self.subcarr_num);
                sb_sch = zeros(self.subcarr_num,1); % used to display round robin
                % Iterates over all subcarriers
                for subc = 1:(self.subcarr_num)
                    % MOD(#Endusers)-th user gets the subcarrier assigned
                    n_user = mod(subc-1,length(self.user_list))+1;
                    sch(n_user,subc) = 1;
                    sb_sch(subc) = n_user;
                end
                
                % Output Scheduling
                fprintf('Scheduling: ');
                fprintf('%i ', sb_sch');
                fprintf('\n');
                
                self.schd = sb_sch;
                
                % Iterate over all users
                for user_iter = 1:length(self.user_list)
                    % Sends list of assigned channels to users
                    self.user_list(user_iter).signaling = sch(user_iter,:);
                end
            else
                sch = -1;
            end
        end
        
        function TBS_ues = modulation(self,TBS,TBS_values)
            % Please note Modulation only returns the modulation for each
            % user. However, it does NOT return the modulation for each
            % subcarrier.
            TBS_ues = TBS_values;
            if (~isempty(self.user_list))
                % Calculate modulation with highest spectral efficiency
                % store spectral efficiency in spec_eff
                self.modu = zeros(length(self.user_list),1);
                % TBS_values = zeros(1,length(self.user_list));
                % do modulation for all users
                for user_iter = 1:length(self.user_list)                  
                    % generate list of subcs assigned to user.
                    % subcarriers_ue holds the information which 
                    % subcarriers are assigned to the given user
                    index_counter = 1; 
                    subcarriers_ue = zeros(1,sum(self.user_list(user_iter).signaling));
                    for subc_iter = 1:self.subcarr_num
                        if self.user_list(user_iter).signaling(subc_iter)==1
                            subcarriers_ue(index_counter)=subc_iter;
                            index_counter = index_counter +1;
                        end
                    end 
                    % generate feedback of user
                    f = self.user_list(user_iter).feedback(self);
                    % calculate best MCS
                    % iterate over all subcarriers of the user
                    % save the varioues MCS values in a vector
                    MCS_values = zeros(1,length(subcarriers_ue));
                    % save the varioues TBS values in a vector
                    TBS_values_ue = zeros(1,length(subcarriers_ue));
                    for subc = 1:length(subcarriers_ue)
                        % check out the subcarrier's cqi
                        cqi_ue = f.CQI(subcarriers_ue(subc));
                        % count how many others subcarrier's have at least
                        % the same cqi. n_rb is the number of recource
                        % blocks considered in TBS
                        n_rb = sum(f.CQI(1,subcarriers_ue)>=cqi_ue); 
                        n_layers = min(f.RI(1,subcarriers_ue));
                        % Calculate maximal TBS
                        TBS_max = self.get_efficiency(cqi_ue)*...
                            params.timestep*n_rb*params.RB_spacing;
                        % Get biggest MCS and TBS possible
                        [TBS_values_ue(subc),MCS_values(subc)] = max(TBS...
                            (:,n_rb,n_layers).*(TBS(:,n_rb,n_layers)<=TBS_max));
                    end
                    % save highest MCS and TBS value for given user
                    self.modu(user_iter) = max(MCS_values);
                    TBS_ues(self.user_list(user_iter).id) = max(TBS_values_ue);
                    
                end
                % Return Modulation
                fprintf('Modulation: ');
                fprintf('%i ', self.modu);
                fprintf('\n');
                
                % Backhaul Output
                % self.bhaul = sum(TBS_values);
                % fprintf('Backhaul: %f\n', self.bhaul);
            end
        end
        
        function eff = get_efficiency(~, cqi)
            % give back the spectral efficiency for a given cqi
            % QPSK from cqi = 1...6
            % 16QAM from cqi = 7...9
            % 64QAM from cqi = 10...15
            switch cqi
                case 1
                    eff = 0.1523;
                case 2
                    eff = 0.2344;
                case 3
                    eff = 0.3770;
                case 4
                    eff = 0.6016;
                case 5
                    eff = 0.8770;
                case 6
                    eff = 1.1758;
                case 7
                    eff = 1.4766;
                case 8
                    eff = 1.9141;
                case 9
                    eff = 2.4063;
                case 10
                    eff = 2.7305;
                case 11
                    eff = 3.3223;
                case 12
                    eff = 3.9023;
                case 13
                    eff = 4.5234;
                case 14
                    eff = 5.1152;
                case 15
                    eff = 5.5547;
            end
        end
                
    end
end