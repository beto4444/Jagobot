classdef Position < handle 
    
    properties(Access = public)
        edge;
        distance;
    end
    
    methods (Access = public)
        function obj = Position(edge, distance)
            obj.edge = edge;
            obj.distance = distance;
        end
        
        function disp(obj)
            disp(['Position: ', ...
                'edge ', int2str(obj.edge.id), ...
                ', distance ', int2str(obj.distance)]);
        end
    end

end
