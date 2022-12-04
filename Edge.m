classdef Edge < handle 
    
    properties (SetAccess = immutable)
        id
        distance
    end
    
    properties (SetAccess = private)
        startNode
        endNode
    end
    
    methods (Access = public)
        function obj = Edge(id, nodeA, nodeB)
            obj.id = id;
            obj.setStartEndNodes(nodeA, nodeB);
            obj.distance = round(sqrt((nodeA.x - nodeB.x)^2 + (nodeA.y - nodeB.y)^2));
        end
        
        function id = getStartNodeId(obj)
            id = obj.startNode.id;
        end
            
        function id = getEndNodeId(obj)
            id = obj.endNode.id;
        end
        
        function addAdjEdgeToNodes(obj)
            obj.startNode.addAdjEdge(obj);
            obj.endNode.addAdjEdge(obj);
        end
        
        function dist = getDistanceFromNode(obj, nodeid, offset)
            if nodeid == obj.startNode.id
                dist = 0 + offset;
            else
                dist = obj.distance - offset;
            end
        end
        
        function [sDist, eDist] = getStartEndDistance(obj, dist, affectedLength)
            sDist = dist - affectedLength/2.0;
            eDist = dist + affectedLength/2.0;
            
            if(sDist < 0)
                sDist = 0;
            end
            if(eDist > obj.distance)
                eDist = obj.distance;
            end
        end
        
        function status = isVertical(obj)
            status = false;
            if(obj.startNode.x == obj.endNode.x)
                status = true;
            end
        end
        
        function status = isHorizontal(obj)
            status = false; 
            if(obj.startNode.y == obj.endNode.y)
                status = true;
            end
        end
        
        function status = isStartNode(obj, node)
            status = false;
            if(node.id == obj.startNode.id)
                status = true;
            end
        end
        
        function status = isEndNode(obj, node)
            status = false;
            if(node.id == obj.endNode.id)
                status = true;
            end
        end
        
        function disp(obj)
            disp(['---- Edge ', int2str(obj.id), ' ----']);
            disp(['Nodes: start-', num2str(obj.startNode.id) ', end-' num2str(obj.endNode.id)]);
        end
    end
    
    methods (Access = private)
        function setStartEndNodes(obj, nodeA, nodeB)
            if(nodeA.x < nodeB.x || nodeA.y < nodeB.y)
                obj.startNode = nodeA;
                obj.endNode = nodeB;
            else
                obj.startNode = nodeB;
                obj.endNode = nodeA;
            end
        end
    end
    
end

