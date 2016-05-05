classdef base_station
    properties
        id;
        pwr;
        pos;
    end
   
    methods
        function obj = base_station(id_attr, pwr_attr, pos_attr)
            obj.id = id_attr;
            obj.pwr = pwr_attr;
            obj.pos = pos_attr;
        end
    end
end