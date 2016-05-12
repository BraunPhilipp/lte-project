classdef base_station
    properties
        id;
        pwr;
        pos;
        frq;
        bndw;
        gain;
        sub;
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
        end
        
        function rsc = resource(self)
            % Generates random resource block
            b = self.bndw/2;
            rsc = randi([self.frq-b self.frq+b]);
        end
        
        function sub = subcarrier(self)
            % Gets 25 independent Subcarriers
            for i = self.frq-b:self.bndw/25:self.frq+b
                self.sub(end+1) = i;
            end
        end
        
    end
end