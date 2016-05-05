classdef user_entity
    properties
        id
        pos
    end
   
    methods
        function obj = user_entity(id_attr, pos_attr)
            obj.id = id_attr;
            obj.pos = pos_attr;
        end
        function dist = distance(base_station_obj)
            % Calculate Distance between Base Station and User Entity %
            tmp_pos = obj.pos - base_station_obj.pos;
            dist = tmp_pos(1) / cos(atand(tmp_pos(2)/tmp_pos(1)));
        end
   end
end