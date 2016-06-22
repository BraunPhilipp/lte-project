classdef user_entity < handle
    properties
        id;
        pos;
        noise;
        ch;
        signaling;
        antenna_num;
        conflict = 0;          %signals whether user is in a conflict
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
            feed.CQI = randi([1,15]);
            feed.RI = randi(max,base.subcarr_num,1);
            feed.PMI = randi(10);
        end
      
    end
end