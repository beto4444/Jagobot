classdef ExploringAlgorithm < handle 
    properties (Constant)

    end
    
    properties (SetAccess = immutable)

    end
    
    properties (SetAccess = private)
        corridors;
        edgeOrder;
        currentIndex;
        vehicles;
        numOfVehicles;
        lastVisited;
        tgtNode;
        initCall;
    end
    
    properties (Access = private)
    
    end
    
    properties (Access = public)

    end
    
    methods (Access = public)
        function obj = ExploringAlgorithm(corridors, vehicles)
            obj.corridors = corridors;
            obj.currentIndex = 0;
            obj.vehicles = vehicles;
            obj.numOfVehicles = length(vehicles);
            obj.lastVisited = zeros(1, obj.corridors.getNumOfEdges());
            obj.tgtNode = [];
            obj.initCall = true;
        end
        
        function position = getNextPosition(obj, step)
            if(obj.initCall)
                position = obj.getInitTgtPosition();
                obj.initCall = false;
            else
                obj.saveLastVisitedStep(step);
                chosenEdge = obj.chooseEdge();
                position = obj.getTgtPosition(chosenEdge);
            end
        end
        
        function updateTgtPositions(obj, step)
            obj.setNewExploreTgtPosIfNeeded(step);
        end
    end
    
    methods (Access = private)
        function position = getInitTgtPosition(obj)
            cEdge = obj.vehicles(1).position.edge;
            entranceNodeId = obj.corridors.entranceNodeId;
            obj.tgtNode = obj.corridors.getNode(entranceNodeId);
            dist = obj.getDistUpdateTgtNode(cEdge);
            position = Position(cEdge, dist);
        end
        
        function saveLastVisitedStep(obj, step)
            cEdgeId = obj.vehicles(1).position.edge.id;
            obj.lastVisited(cEdgeId) = step;
        end
        
        function chosenEdge = chooseEdge(obj)
            chosenEdge = [];
            num = obj.tgtNode.getNumOfAdjEdges();
            minStep = inf;
            for i = 1:num
                edge = obj.tgtNode.getAdjEdge(i);
                if(obj.lastVisited(edge.id) < minStep)
                    chosenEdge = edge;
                    minStep = obj.lastVisited(edge.id);
                end
            end
        end
        
        function position = getTgtPosition(obj, chosenEdge)
            dist = obj.getDistUpdateTgtNode(chosenEdge);
            position = Position(chosenEdge, dist);
        end
        
        function dist = getDistUpdateTgtNode(obj, edge)
            if(edge.isStartNode(obj.tgtNode))
                dist = edge.distance;
                obj.tgtNode = edge.endNode;
            else
                dist = 0;
                obj.tgtNode = edge.startNode;
            end
        end
        
        function setNewExploreTgtPosIfNeeded(obj, step)
            if(obj.isNewTgtPosNeeded())
                currentTgtPos = obj.getNextPosition(step);
                for i = 1:obj.numOfVehicles
                    obj.vehicles(i).setExploreTgtPos(currentTgtPos);
                end
            end
        end
        
        function status = isNewTgtPosNeeded(obj)
            status = false;
            for i = 1:obj.numOfVehicles
                if(obj.vehicles(i).exploreTgtPosReached)
                    status = true;
                end
            end
        end
    end
end