classdef CorridorStructure < handle
    properties (SetAccess = immutable)
        adjMatrix
    end
    
    properties (SetAccess = private)
        weightedAdjMatrix;
        maxY = 0;
        maxX = 0;
    end
    
    properties (Access = private)
        nodes;
        edges;
    end
    
    properties (Access = public)
        entranceNodeId
    end
    
    methods (Access = public)
        function obj = CorridorStructure(nodes, adjMatrix)
            obj.generateNodes(nodes);
            obj.adjMatrix = adjMatrix;
        end
    
        function obj = init(obj)
            obj.generateEdges();
            obj.createWeightedAdjMatrix();%Poprawiono literówkę - z createwieghtedadjmatrix na createweightedadjmatrix
            obj.entranceNodeId = 5;
            obj.computeAdjEdges();
        end
        
        function node = getNode(obj, nodeId)
            node = obj.nodes{nodeId};
        end
        
        function num = getNumOfNodes(obj)
            num = length(obj.adjMatrix);
        end

        function edge = getEdge(obj, edgeId)
            edge = obj.edges{edgeId};
        end
        
        function num = getNumOfEdges(obj)
            num = length(obj.edges);
        end
        
        function edge = getEdgeWithNodesId(obj, startId, endId)
            edge = [];
            for i = 1:obj.nodes{startId}.getNumOfAdjEdges()
                if(obj.nodes{startId}.getAdjEdge(i).getEndNodeId() == endId)
                    edge = obj.nodes{startId}.getAdjEdge(i);
                    break
                end
            end
        end
        
        function distance = computeDistance(obj, startPos, endPos)
            path = obj.findShortestPath(startPos, endPos);
            if(length(path) == 2)
                distance = abs(startPos.distance - endPos.distance);
            else
                tmpPath = path(2:length(path) - 1);
                distance = startPos.edge.getDistanceFromNode(tmpPath(1), startPos.distance);
                while(length(tmpPath) > 1)
                    edge = obj.getEdgeWithNodesId(tmpPath(1), tmpPath(2));
                    if(isempty(edge))
                        edge = obj.getEdgeWithNodesId(tmpPath(2), tmpPath(1));
                    end
                    distance = distance + edge.distance;
                    tmpPath = tmpPath(2:length(tmpPath));
                end
                distance = distance + endPos.edge.getDistanceFromNode(tmpPath(1), endPos.distance);
            end
        end
        
        function path = findShortestPath(obj, startPos, endPos)
            startPos = obj.updateIfNodePos(startPos);
            endPos = obj.updateIfNodePos(endPos);
            startNode = length(obj.adjMatrix) + 1;
            endNode = startNode + 1;
            if(startPos.edge.id ~= endPos.edge.id)
                adjM = obj.weightedAdjMatrix;
                adjM = obj.addFalseNode(adjM, startNode, startPos);
                adjM = obj.addFalseNode(adjM, endNode, endPos);
%                 [dist,path,pred] = graphshortestpath(sparse(adjM),startNode,endNode,'directed',false);
                  path = shortestpath(graph(sparse(adjM)),startNode,endNode);
%                   zmieniono graphshortestpath na shortestpath. Powód:
%                   graphshortestpath przestał być wspierany w matlabie
%                   2022b
            else
                path = [startNode, endNode];
            end
        end
        
        function pos = updateIfNodePos(obj, pos)
            if(pos.distance == 0)
                pos.distance = 0.001;
            elseif(pos.distance == pos.edge.distance)
                pos.distance = pos.distance - 0.001;
            end
        end
        
        function test(obj)
            pos1 = Position(obj.edges{2}, 300);
            pos2 = Position(obj.edges{5}, 350);
            obj.computeDistance(pos1, pos2);
            obj.findShortestPath(pos1, pos2);
        end
        
        function disp(obj)
            disp('CorridorStructure')
            for i = 1:length(obj.adjMatrix)
                obj.nodes{i}.disp();
            end
            for i = 1:length(obj.edges)
                obj.edges{i}.disp();
            end
            disp(['Max: (' num2str(obj.maxX), ',' num2str(obj.maxY), ')']);
        end
    end
    
    methods (Access = private)
        function generateNodes(obj, nodes)
            for i = 1:length(nodes)
                obj.nodes{i} = Node(i, nodes{i}(1), nodes{i}(2));
                if(nodes{i}(1) > obj.maxX)
                    obj.maxX = nodes{i}(1);
                end
                if(nodes{i}(2) > obj.maxY)
                    obj.maxY = nodes{i}(2);
                end
            end
        end
        
        function generateEdges(obj)
            index = 1;
            for row = 1:size(obj.adjMatrix,1)
                for col = row:size(obj.adjMatrix,2)
                    if (obj.adjMatrix(row, col) == 1)
                        obj.edges{index} = Edge(index, obj.nodes{row}, obj.nodes{col});
                    index = index + 1;
                    end
                end
            end
        end
        
        function createWeightedAdjMatrix(obj)
            obj.weightedAdjMatrix = obj.adjMatrix;
            for i = 1:length(obj.edges)
                startId = obj.edges{i}.getStartNodeId();
                endId = obj.edges{i}.getEndNodeId();
                dist = obj.edges{i}.distance;
                obj.weightedAdjMatrix(startId, endId) = dist;
                obj.weightedAdjMatrix(endId, startId) = dist;
            end
        end
        
        function computeAdjEdges(obj)
            for i = 1:length(obj.edges)
                obj.edges{i}.addAdjEdgeToNodes();
            end            
        end
        
        function adjM = addFalseNode(obj, adjM, nodeId, position)
            startId = position.edge.getStartNodeId();
            endId = position.edge.getEndNodeId();
            
            adjM = obj.setConnection(adjM, startId, endId, 0);
            adjM(nodeId, nodeId) = 0;
            adjM = obj.setConnection(adjM, startId, nodeId, position.distance);
            adjM = obj.setConnection(adjM, endId, nodeId, position.edge.distance - position.distance);
        end
        
        function adjM = setConnection(obj, adjM, row, col, val)
            adjM(row, col) = val;
            adjM(col, row) = val;
        end

    end

end

