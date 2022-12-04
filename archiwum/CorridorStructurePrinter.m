classdef CorridorStructurePrinter 
    properties (Constant)
        namesOffset = 20;
    end
    
    properties (Access = public)
        structure;
    end
    
    methods (Access = public)
        function obj = CorridorStructurePrinter(corridor)
            obj.structure = corridor;
        end
        
        function print(obj)
            fig = figure('Color', [1, 1, 1]);
%              title('Corridor structure - view from the top');
            hold on;
            grid on;
            box on;
            
            obj.printEdges()
            obj.printNodes()
            obj.printEdgeNames()
            obj.printNodeNames()
        end
    end
        
        
    methods (Access = public)
        function [x,y] = getLinesxy(obj)
            xFrom = [];
            yFrom = [];
            xTo = [];
            yTo = [];
            
            for row = 1:size(obj.structure.adjMatrix,1)
                for col = row:size(obj.structure.adjMatrix,2)
                    if (obj.structure.adjMatrix(row, col) == 1)
                        xFrom = [xFrom obj.structure.getNode(row).x];
                        yFrom = [yFrom obj.structure.getNode(row).y];
                        xTo = [xTo obj.structure.getNode(col).x];
                        yTo = [yTo obj.structure.getNode(col).y];
                    end
                end
            end
            
            x = [xFrom;xTo];
            y = [yFrom;yTo];
        end
        
        function printEdges(obj)
            [x,y]=obj.getLinesxy();
            
            xOffset = max(max(x))*0.05;
            yOffset = max(max(y))*0.05;           
            
            plot(x,y,'k', 'LineWidth', 5);
            
            axis([min(min(x)) - xOffset, max(max(x)) + xOffset,... 
                min(min(y)) - yOffset, max(max(y)) + yOffset]);
        end
        
        function printNodes(obj)
            for nodeId = 1:obj.structure.getNumOfNodes()
                plot(obj.structure.getNode(nodeId).x, obj.structure.getNode(nodeId).y,...
                    '.', 'MarkerSize', 10, 'LineWidth', 2, ...
                    'Color', [0.2,0.8,0.4]);
            end
        end
        
        function printEdgeNames(obj)
            for i = 1:obj.structure.getNumOfEdges()
                [x, y] = obj.getxyCenterOfEdge(obj.structure.getEdge(i));
                text(x + obj.namesOffset, y + obj.namesOffset, ... 
                strcat('edge: ', int2str(obj.structure.getEdge(i).id)), ...
                'Color', [1,0,0]);
            end
        end
        
        function [x, y] = getxyCenterOfEdge(obj, edge)
            startNode = edge.startNode;
            endNode = edge.endNode;
            x = (endNode.x + startNode.x)/2;
            y = (endNode.y + startNode.y)/2;            
        end
        
        function printNodeNames(obj)
            for i = 1:obj.structure.getNumOfNodes()
                x = obj.structure.getNode(i).x + obj.namesOffset;
                y = obj.structure.getNode(i).y + obj.namesOffset;                
                text(x, y, strcat('node: ', int2str(obj.structure.getNode(i).id)), ...
                'Color', [0.2,0.8,0.4]);
            end
        end
    end
end