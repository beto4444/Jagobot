classdef ComFallout < handle
    properties (SetAccess = immutable)
        id;
        appearanceTime;
        position;
        duration;
        affectedLength;
        comRange;
        startDistance;
        endDistance;
    end
    
    properties (Access = public)

    end
    
    methods (Access = public)
        function obj = ComFallout(inputData, corridors)
            obj.id = inputData(1);
            obj.position = Position(corridors.getEdge(inputData(2)), inputData(3));
            obj.appearanceTime = inputData(5);
            obj.duration = inputData(6);
            obj.affectedLength = inputData(4);
            obj.comRange = inputData(7);
            [obj.startDistance, obj.endDistance] = obj.position.edge.getStartEndDistance(obj.position.distance, obj.affectedLength);
        end
        
        function status = isInRange(obj, position)
            status = false;
            if(position.edge.id == obj.position.edge.id & position.distance <= obj.endDistance & position.distance >= obj.startDistance)
                status = true;
            end
        end
        
        function disp(obj)
            disp(['---- ComFallout ', num2str(obj.id), ' ----']);
            obj.position.disp();
            disp(['Affected length ', '(', num2str(obj.affectedLength), '): ', ...
            num2str(obj.startDistance), ' - ', ...
            num2str(obj.endDistance)]);
        end
    end
end