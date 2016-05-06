classdef user_entity
    properties
        id
        pos
    end
   
    methods
        function obj = user_entity(id_attr, pos_attr)
            % Constructor
            obj.id = id_attr;
            obj.pos = pos_attr;
        end

        function dist = distance(self, b)
            % Calculate Distance between Base Station and User Entity
            tmp_pos = self.pos - b.pos;
            dist = abs(tmp_pos(1) / cos(atand(tmp_pos(2)/tmp_pos(1))));
        end
        
        function fr = friis(self, b)
            lambda = 300000000 / b.frq;
            % need to lookup additional gain values
            fr = b.pwr + b.gain + 20 * log10(lambda/(4*pi*self.distance(b)));
        end
        
        function s = snr(self, b, sel)
            % Returns Signal-To-Noise Ratio
            noise = 0;
            sigma = randn;
            % Sum over all elements except #sel
            for i = b(1:sel:end)
                noise = noise + dbw(self.friis(i));
            end
            s = dbw(b(sel).pwr) / (noise + sigma);
        end

    end
end

function d = dbw(val)
    % Decibel to Watts
    d = 10^(val/10);
end