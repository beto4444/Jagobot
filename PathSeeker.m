classdef PathSeeker < handle 
    properties (Constant)
        TGT_REACHED = 0.001;
    end
    
    properties (SetAccess = immutable)
        corridors;
    end
    
    properties (SetAccess = private)
        targetPos;
        edgePathToTarget;
        nodePathToTarget;
        pathToTargetPtr;
        turningAround;
    end
    
    
    properties (Access = public)
        isTargetEmpty;
        vehPosition;
        vehDirection;
    end
    
    methods (Access = public)
        function obj = PathSeeker(corridors)
            obj.corridors = corridors;
            obj.targetPos = [];
            obj.nodePathToTarget = [];
            obj.pathToTargetPtr = [];
            obj.edgePathToTarget = [];
            obj.isTargetEmpty = true;
            obj.turningAround = false;
        end
        
        function setTarget(obj, targetPos)
            obj.targetPos = targetPos;
            obj.isTargetEmpty = false;
            obj.findPathToTarget();
        end
        
        function clearTarget(obj)
            obj.targetPos = [];
            obj.isTargetEmpty = true;
        end
        
        function command = getMoveCommand(obj)
            command = [];

            if(isempty(obj.targetPos))
                command = VehIntCmd.TargetEmpty;
            elseif(obj.isTargetReached())
                command = VehIntCmd.TargetReached;
            elseif(obj.isTargetNear())
                command = VehIntCmd.SlowMove;
            else
                command = obj.getNextCommand();
            end
            
            if(isempty(command))
                command = VehIntCmd.Stop;
            end
        end
        
        function edge = getNextEdge(obj)
            if(obj.isNextEdge())
                edge = obj.edgePathToTarget(obj.pathToTargetPtr);
                obj.pathToTargetPtr = obj.pathToTargetPtr + 1;
            end
        end
    end
    
    methods (Access = private)
        function command = getNextCommand(obj)
            command = [];
            if(obj.turningAround)
                obj.turningAround = false;
                command = VehIntCmd.MoveBack;
            elseif(obj.isSameEdge() & obj.isCorrectDirectionToTarget())
                command = VehIntCmd.Move;
            elseif(obj.isSameEdge() & ~obj.isCorrectDirectionToTarget())
                obj.turningAround = true;
                command = VehIntCmd.Stop;
            elseif(obj.isCorrectTargetPath() & obj.isCorrectDirectionToNode())
                command = VehIntCmd.Move;
            elseif(obj.isCorrectTargetPath() & ~obj.isCorrectDirectionToNode())
                obj.turningAround = true;
                command = VehIntCmd.Stop;
            end
        end
        
        function status = isSameEdge(obj)
            status = false;
            if(obj.vehPosition.edge.id == obj.targetPos.edge.id)
                status = true;
            end
        end
        
        function status = isCorrectTargetPath(obj)
            status = false;
            if(length(obj.nodePathToTarget) > 2 & ismember(obj.pathToTargetPtr, 2:length(obj.nodePathToTarget)))
                status = true;
            end
        end
        
        function status = isNextEdge(obj)
            status = false;
            if(ismember(obj.pathToTargetPtr - 1, 1:length(obj.edgePathToTarget)))
                status = true;
            end
        end
    
        function findPathToTarget(obj)
            obj.nodePathToTarget = obj.corridors.findShortestPath(obj.vehPosition, obj.targetPos);
            obj.pathToTargetPtr = 2;
            obj.generateEdgePath();
        end

        function generateEdgePath(obj)
            obj.edgePathToTarget = [];
            tmpNodePath = obj.nodePathToTarget(2:length(obj.nodePathToTarget) - 1);
            
            obj.edgePathToTarget = obj.vehPosition.edge;
            if(length(tmpNodePath) > 0)
                while(length(tmpNodePath) > 1)
                    obj.edgePathToTarget = [obj.edgePathToTarget obj.getNextEdgeToPath(tmpNodePath)];
                    tmpNodePath = tmpNodePath(2:length(tmpNodePath));
                end
                obj.edgePathToTarget = [obj.edgePathToTarget obj.targetPos.edge];
            end
        end
        
        function edge = getNextEdgeToPath(obj, nodePath)
            startId = nodePath(1);
            endId = nodePath(2);
            edge = obj.corridors.getEdgeWithNodesId(startId, endId);
            if(isempty(edge))
                edge = obj.corridors.getEdgeWithNodesId(endId, startId);
            end
        end
        
        function status = isTargetNear(obj)
            status = obj.isTargetInDist(Validation.TGT_NEAR);
        end
        
        function status = isTargetReached(obj)
            status = obj.isTargetInDist(obj.TGT_REACHED);
        end
        
        function status = isTargetInDist(obj, dist)
            diff = abs(obj.vehPosition.distance - obj.targetPos.distance);
            if(obj.isSameEdge() & diff <= dist)
                status = true;
            else
                status = false;
            end
        end
        
        function correctDirection = isCorrectDirectionToTarget(obj)
            correctDirection = false;
            diff = obj.targetPos.distance - obj.vehPosition.distance;
            if((diff > 0 & obj.vehDirection == 1) | (diff < 0 & obj.vehDirection == -1))
                correctDirection = true;
            end
        end
        
        function status = isCorrectDirectionToNode(obj)
            status = false;
            startId = obj.vehPosition.edge.getStartNodeId();
            nodeId = obj.nodePathToTarget(obj.pathToTargetPtr);
            if((startId == nodeId & obj.vehDirection == -1) | (startId ~= nodeId & obj.vehDirection == 1))
                status = true;
            end
        end
        
        function status = isNodeReached(obj)
            startId = obj.vehPosition.edge.getStartNodeId();
            nodeId = obj.nodePathToTarget(obj.pathToTargetPtr);
            if(startId ~= nodeId)
                distToReach = obj.vehPosition.edge.distance
            else
                distToReach = 0;
            end
            diff = abs(obj.vehPosition.distance - distToReach);
            if(diff <= Validation.TGT_NEAR)
                status = true;
            else
                status = false;
            end
        end
    end
end