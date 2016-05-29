classdef base_station
    % Base Station
    properties
        id; 
        pwr; % dBm
        pos; % m [x y]
        frq; % Hz
        bndw; % Hz
        gain;
        sub;
        user_list; %List of connected user entities
    end
   
    methods
        function obj = base_station(id_attr, pwr_attr, pos_attr, frq_attr, bndw_attr, gain_attr)
            % Constructor
            obj.id = id_attr;
            obj.pwr = pwr_attr;
            obj.pos = pos_attr;
            obj.frq = frq_attr;
            obj.bndw = bndw_attr;
            obj.gain = gain_attr;
            obj.sub = [];
            obj.user_list = [];
        end
        
        function sub = subcarrier(self)
            % Gets 25 independent Subcarriers
            for i = self.frq-b:self.bndw/25:self.frq+b
                self.sub(end+1) = i;
            end
        end
        
        function sch = scheduling(self)
            %Coordinates scheduling activities (so far, RoundRobin)
            %Problem = what to do with CQI, PMI, RI???
           for i = 1:length(self.user_list) %Iterates on all users
                sch(i) = zeros(length(self.sub)); %(empty) signals for all users are generated
           end
            
           for i = 1:length(self.sub)   %Iterates on all subcarriers
               x = mod(i,length(self.user_list)); %iMOD(#Endusers)-th user gets the subcarrier assigned 
               sch(x,i) = 1;%mere Round-Robin process so far
           end
           
           for i = 1:length(self.user_list) %Iterates on all users
               self.user_list(i).signaling = sch(i); %Sends list of assigned channels
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