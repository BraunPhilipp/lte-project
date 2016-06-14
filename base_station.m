classdef base_station < handle
    % Base Station
    properties
        id; 
        pwr; % dBm
        pos; % m [x y]
        frq; % Hz
        bndw; % Hz
        delta_freq;
        gain;
        n_subc;
        user_list; %List of connected user entities
    end
   
    methods
        function obj = base_station(id_attr, pwr_attr, pos_attr, frq_attr, n_subc_attr, bndw_attr, gain_attr)
            % Constructor
            obj.id = id_attr;
            obj.pwr = pwr_attr;
            obj.pos = pos_attr;
            obj.frq = frq_attr;
            obj.bndw = bndw_attr;
            obj.n_subc = n_subc_attr;
            obj.gain = gain_attr;
            %obj.sub = (frq_attr-bndw_attr/2):(bndw_attr/25):(frq_attr+bndw_attr/2);
            
            obj.user_list = [];
        end
        
%         function sub = subcarrier(self)
%             % Gets 25 independent Subcarriers
%             for i = self.frq-self.bndw/2:self.bndw/25:self.frq+self.bndw/2
%                 self.sub(end+1) = i;
%             end
%         end
        
        function sch = scheduling(self)
           % Coordinates scheduling activities (so far, RoundRobin)
           % Problem = what to do with CQI, PMI, RI???
           param = feed_param();
           numb_sub = param(2).n_subcarriers; %number of subcarriers
           sch = zeros(length(self.user_list), numb_sub); %(empty) signals for all users are generated
           
           for subc = 0:(numb_sub-1) % Iterates on all subcarriers
               n_user = mod(subc,length(self.user_list))+1; % MOD(#Endusers)-th user gets the subcarrier assigned 
               sch(n_user,subc+1) = 1; % mere Round-Robin process so far
           end
           
           for user_list_iter = 1:length(self.user_list) % Iterates on all users
               self.user_list(user_list_iter).signaling = sch(user_list_iter,:); % Sends list of assigned channels
           end
           
        end
        
        function modu = get_modulation(self)
            % calculate modulation with highest spectral efficiency
            % store spectral efficiency in spec_eff:
            modu = zeros(length(self.user_list),1);
            
            for user_iter = 1:length(self.user_list)
                
                spec_eff = zeros(3,1);
                % get a feedback from a user:
                f = self.user_list(user_iter).generate_feedback();
                % now find out for all modulation modules
                % 1.modulation = QPSK
                for subc_iter = 1:self.n_subc
                    %if user is assigned to given subcarrier:
                    if self.user_list(user_iter).signaling(subc_iter)==1
                        if f.CQI(subc_iter)>6
                            % add to spectral efficiency
                            spec_eff(1) = spec_eff(1) + self.get_efficiency(6);
                        else
                            spec_eff(1) = spec_eff(1) + self.get_efficiency(f.CQI(subc_iter));
                        end
                    end    
                end
                % bottleneck = smallest CQI value -> should be transmitted
                % spectral efficiency = smallest efficiency
                % data rate = spectral efficiency * df(subcarrier) * number
                % of subcarriers
                % packet = data rate * time (1 ms)
                % 2.modulation = 16QAM
                for subc_iter = 1:f.n_subcarriers
                    %if user is assigned to given subcarrier:
                    if self.user_list(user_iter).signaling(subc_iter)==1
                        if f.CQI(subc_iter)>9
                            % add to spectral efficiency
                            spec_eff(2) = spec_eff(2) + self.get_efficiency(9);
                        elseif f.CQI(subc_iter)<7
                            % not sure what to do if CQI is too low for given
                            % modulation
                        else
                            spec_eff(2) = spec_eff(2) + self.get_efficiency(f.CQI(subc_iter));
                        end
                    end    
                end
                % 3.modulation = 64QAM
                for subc_iter = 1:f.n_subcarriers
                    %if user is assigned to given subcarrier:
                    if self.user_list(user_iter).signaling(subc_iter)==1
                        if f.CQI(subc_iter)<10
                            % not sure what to do if CQI is too low for given
                            % modulation
                        else
                            spec_eff(3) = spec_eff(3) + self.get_efficiency(f.CQI(subc_iter));
                        end
                    end    
                end

                % choose modulation with highest bit/s:
                [~,modu(user_iter)]= max(spec_eff);
            end
                       
        end
        
        function eff = get_efficiency(~,cqi)
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

% rand Channel Quality Indicator (CQI) {0,15} -> 0 high throughput
% 0  -> Low Coding Rate & High Modulation
% 15 -> High Coding Rate (QAM) & Low Modulation
% High Modulation (64 QAM)

% Low spectral efficiency [bit/sec * Hz]
% rand Pre-coding Matrix Indicator PMI
% rand Rank Indicator RI

% Central Unit (Interference between Basestations)
% Scheduler sets different Subcarriers for User Entities

% Biterror Rate 10^2 -> SNR -> QAM

% Signaling (Round Robin)
% Resource Element == Spectral Efficiency * T_sym * Delta<F>