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
        end
        
        function beam = beamforming(self)
            if (~isempty(self.user_list))
                schd = zeros(length(self.schd),1);
                for schd_iter = 1:length(self.schd)
                    % count previous occurences
                    num_occ = sum(self.schd(schd_iter) == self.schd(1:schd_iter)) - 1;
                    schd(schd_iter) = num_occ;
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
            % Coordinates scheduling activities (mere RoundRobin so fardd)
            if (~isempty(self.user_list))
                % Generate empty Signals for all users
                sch = zeros(length(self.user_list), self.subcarr_num);
                sb_sch = zeros(self.subcarr_num,1); % used to display round robin
                % Iterates over all subcarriers
                for subc = 0:(self.subcarr_num-1)
                    % MOD(#Endusers)-th user gets the subcarrier assigned
                    n_user = mod(subc,length(self.user_list))+1;
                    sch(n_user,subc+1) = 1;
                    sb_sch(subc+1) = n_user;
                end
                
                % Output Scheduling
                fprintf('Scheduling: ');
                fprintf('%i ', sb_sch');
                fprintf('\n');
                
                self.schd = sb_sch;
                
                % Iterate over all users
                for user_iter = 1:length(self.user_list)
                    % Sends list of assigned channels
                    self.user_list(user_iter).signaling = sch(user_iter,:);
                end
            else
                sch = -1;
            end
        end
        
        function modu = modulation(self)
            % Please note Modulation only returns the modulation for each
            % user. However, it does NOT return the modulation for each
            % subcarrier.
            if (~isempty(self.user_list))
                % Calculate modulation with highest spectral efficiency
                % store spectral efficiency in spec_eff
                modu = zeros(length(self.user_list),1);

                for user_iter = 1:length(self.user_list)
                    % Initialize Spectral Efficiency
                    spec_eff = zeros(3,1);
                    % Get a feedback from a user
                    f = self.user_list(user_iter).feedback(self);

                    % Modulation #1 = QPSK
                    if (f.CQI > 6)
                        % + spec_eff offset ???
                        spec_eff(1) = spec_eff(1) + self.get_efficiency(6);
                    else
                        spec_eff(1) = spec_eff(1) + self.get_efficiency(f.CQI);
                    end

                    % bottleneck = smallest CQI value -> should be transmitted
                    % spectral efficiency = smallest efficiency
                    % data rate = spectral efficiency * df(subcarrier) * number
                    % of subcarriers
                    % packet = data rate * time (1 ms)

                    % Modulation #2 = 16QAM
                    if (f.CQI > 9)
                        spec_eff(2) = spec_eff(2) + self.get_efficiency(9);
                    elseif f.CQI < 7
                        % CQI too low for given modulation
                    else
                        spec_eff(2) = spec_eff(2) + self.get_efficiency(f.CQI);
                    end

                    % Modulation #3 = 64QAM
                    if (f.CQI < 10)
                        % CQI too low for given modulation
                    else
                        spec_eff(3) = spec_eff(3) + self.get_efficiency(f.CQI);
                    end

                    % Choose Modulation with highest bit/s
                    [~,Index] = max(spec_eff);
                    modu(user_iter) = Index;
                end
                % Return Modulation
                fprintf('Modulation: ');
                fprintf('%i ', modu);
                fprintf('\n');
                
                self.modu = modu;
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