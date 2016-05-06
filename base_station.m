classdef base_station
    properties
        id;
        pwr;
        pos;
        frq;
        bndw;
        gain;
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
        end
    end
end