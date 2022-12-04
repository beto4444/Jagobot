classdef Node < handle
   
    properties (SetAccess = immutable)
        id; 
        x;
        y;
    end
    
    properties (SetAccess = private)
        adjEdges;
    end
    
    methods
        function obj = Node(id, x, y)
            obj.id = id;
            obj.x = x;
            obj.y = y;
            obj.adjEdges = [];
        end
        
        function addAdjEdge(obj, edge)
            obj.adjEdges = [obj.adjEdges edge];
        end
        
        function num = getNumOfAdjEdges(obj)
            num = length(obj.adjEdges);
        end
        
        function edge = getAdjEdge(obj, edgeNum)
            edge = obj.adjEdges(edgeNum);
        end
        
        function edgeReturned = getAdjEdgeWithId(obj, edgeId)
            edgeReturned = NaN;
            for edge = 1:length(obj.adjEdges)
                if(obj.adjEdges(edge).Id == edgeId)
                    edgeReturned = obj.adjEdges(edge);
                end
            end
        end
    end
end

