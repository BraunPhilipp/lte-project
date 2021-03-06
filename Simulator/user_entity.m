classdef user_entity < handle
    properties
        id;
        pos;
        noise;
        ch;
        signaling;
        antenna_num; 
    end
   
    methods
        function obj = user_entity(id_attr, pos_attr, noise_attr, antn_attr)
            % Constructor
            obj.id = id_attr;
            obj.pos = pos_attr;
            obj.noise = noise_attr;
            obj.ch = channel();
            obj.signaling = [];
            obj.antenna_num = antn_attr;
        end
        
        function feed = feedback(self, base)
            % Get max number of Streams
            if self.antenna_num < base.antenna_num
                max = self.antenna_num;
            else
                max = base.antenna_num;
            end
            
            % Generate random Feedback
            feed.CQI = randi(15,1,25); % one cqi for every subcarrier
            feed.RI = randi(max,1,base.subcarr_num);
            feed.PMI = randi(10);
        end
      
    end
end