classdef Obstacle < Obstruction
    properties (Constant) 
        VDERATEMAX = 0.1;
    end
    
    properties (SetAccess = immutable)
        id;
        position;
        severity;
        velocityDerate;
    end
    
    properties (SetAccess = protected)
        affectedLength;
        startDistance;
        endDistance;
    end
    
    
    methods (Access = public)
        function obj = Obstacle(inputData, corridors)
            obj.id = inputData(1);
            obj.position = Position(corridors.getEdge(inputData(2)), inputData(3));
            obj.severity = inputData(4);
            obj.velocityDerate = obj.severity*obj.VDERATEMAX;
            obj.affectedLength = inputData(5);
            [obj.startDistance, obj.endDistance] = obj.position.edge.getStartEndDistance(obj.position.distance, obj.affectedLength);
        end
        
        function impacts = impacts(obj, position)
            impacts = false;
            if(position.edge.id == obj.position.edge.id)
                if(position.distance >= obj.startDistance & position.distance <= obj.endDistance)
                    impacts = true;
                end
            end
        end
        
        function damage = getDamage(obj)
            damage = obj.severity/10;
        end
        
    end
end

