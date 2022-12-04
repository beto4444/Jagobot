classdef SimulationPrinter < handle
    properties (Constant)

    end
    
    properties (Access = private)
        corridorColor = [1 1 1];
        corridorWidth = 30;
        
        obstacleWidth = 15;
        
        FruitBushMarker = 'v';
        FruitBushSize = 13;
        FruitBushLineWidth = 2;
        FruitBushActiveColor = [0 0 0];
        FruitBushReloaddMarker = '.';
        
        vehExploringColor = [0 0 0];
        vehCoordinationColor = [0 0 0];
        vehAssistingColor = [0 0 0];
        vehWaitingColor = [0 0 0];
        vehGroup1EdgeColor = [1 1 1];
        vehGroup2EdgeColor = [1 1 1];
        vehMarkerSize = 7;
        vehLineWidth = 2;
        
        falloutsOffset = 30;
        falloutsWidth = 20;
        falloutsColor = [1 0.68 0.7];
        falloutsMarker = '-';
        
        FruitBush;
        fallouts;
        
        numOfNodes;
        numOfEdges;
        
        h;
    end
    
    properties (SetAccess = immutable)
        graph;
        sim;
        structure;
    end
    
    
    methods (Access = public)
        function obj = SimulationPrinter(sim, graph)
            obj.sim = sim;
            obj.graph = graph;
            obj.structure = obj.sim.corridors;
            obj.FruitBush = [];
            obj.h.FruitBush = [];
            obj.fallouts = [];
            obj.h.fallouts = [];
        end
        
        function init(obj)
            hold on;
            xlabel('x length [m]');
            ylabel('y length [m]');
            obj.printEdges();
            obj.printNodes();
            obj.printObstacles();
            obj.printVehicles();
            obj.numOfNodes = obj.structure.getNumOfNodes();
            obj.numOfEdges = obj.structure.getNumOfEdges();
        end
        
        function update(obj)
            obj.updateVehicles();
            obj.updateFruitBush();
            obj.updateFallouts();
        end
        
        function printLegend(obj)
            axis off;
            hold on;
            
            obj.printFullLegend();
        end
    end
        
        
    methods (Access = private)
       
        function printEdges(obj)
            [x,y] = getLinesxy(obj);
            obj.h.corridors = plot(x, y, 'LineWidth', obj.corridorWidth, ...
                'Color', obj.corridorColor);
            xOffset = max(max(x))*0.1;
            yOffset = max(max(y))*0.1;
            axis([min(min(x)) - xOffset, max(max(x)) + xOffset,... 
                min(min(y)) - yOffset, max(max(y)) + yOffset]);
            uistack(obj.h.corridors, 'bottom');
        end
        
        function printNodes(obj)
            for nodeId = 1:obj.structure.getNumOfNodes()
                h = plot(obj.structure.getNode(nodeId).x, obj.structure.getNode(nodeId).y,...
                    '.', 'MarkerSize', 88, 'Color', obj.corridorColor);
                uistack(h, 'bottom');
            end
        end
        
        function printVehicles(obj)
            for i = 1:length(obj.sim.vehicleGroups)
                obj.printGroup(obj.sim.vehicleGroups(i), i);
            end
        end
        
        function printGroup(obj, group, groupId)
            for i = 1:group.numOfVehicles
                [vehx, vehy] = obj.getXYFromPosition(group.vehicles(i).position);
                symbol = obj.getTurn(group.vehicles(i).position, group.vehicles(i).direction);
                groupColor = obj.vehGroup1EdgeColor;
                if(groupId == 2)
                    groupColor = obj.vehGroup2EdgeColor;
                end
                obj.h.group(groupId).vehicles(i) = plot(vehx, vehy, symbol, ...
                    'MarkerSize', obj.vehMarkerSize, ...
                    'LineWidth', obj.vehLineWidth, ...
                    'MarkerFaceColor', [1 1 1], ...
                    'MarkerEdgeColor', [1 1 1]);
            end
        end
        
        function printObstacles(obj)
            inactiveObstacles = obj.sim.obstaclesHandler.getAllInactive();
            for i = 1:length(inactiveObstacles)
                edge = inactiveObstacles(i).position.edge;
                if(edge.isHorizontal())
                    x1 = inactiveObstacles(i).startDistance + edge.startNode.x;
                    x2 = inactiveObstacles(i).endDistance + edge.startNode.x;
                    y1 = edge.startNode.y;
                    y2 = y1;
                else
                    x1 = edge.startNode.x;
                    x2 = x1;
                    y1 = inactiveObstacles(i).startDistance + edge.startNode.y;
                    y2 = inactiveObstacles(i).endDistance + edge.startNode.y;
                end
                color(1:3) = inactiveObstacles(i).severity/2 + 0.3;
                obj.h.obstacles(i) = plot([x1 x2], [y1 y2], 'Color', color, ...
                    'LineWidth', obj.obstacleWidth);
            end
        end
        
        function updateVehicles(obj)
            for gr = 1:length(obj.h.group)
                group = obj.sim.vehicleGroups(gr);
                for i = 1:length(obj.h.group(gr).vehicles)
                    hVeh = obj.h.group(gr).vehicles(i);
                    [vehx, vehy] = obj.getXYFromPosition(group.vehicles(i).position);
                    symbol = obj.getTurn(group.vehicles(i).position, group.vehicles(i).direction);
                    color = obj.getVehColor(group.vehicles(i));
                    set(hVeh, 'XData', vehx, 'YData', vehy, 'Marker', symbol, 'MarkerFaceColor', color);                
                end
            end
        end
        

        function id = getNextId(obj, id)
            id = id + 1;
        end
        
        function color = getVehColor(obj, veh)
            switch veh.state
                case VehState.Coordination
                    color = obj.vehCoordinationColor;
                case VehState.Assisting
                    color = obj.vehAssistingColor;
                case VehState.Waiting
                    color = obj.vehWaitingColor;
                otherwise
                    color = obj.vehExploringColor;
            end
        end
        
        function updateFruitBush(obj)
            obj.plotActivatedFruitBush();
            obj.updateReloaddFruitBush();
        end
        
        function plotActivatedFruitBush(obj)
            activatedFruitBush = obj.sim.FruitBushHandler.activated;
            for i = 1:length(activatedFruitBush)
                obj.FruitBush = [obj.FruitBush activatedFruitBush(i)];
                [x, y] = obj.getXYFromPosition(activatedFruitBush(i).position);
                h = plot(x, y, obj.FruitBushMarker, ...
                    'Color', obj.FruitBushActiveColor, ...
                    'MarkerSize', obj.FruitBushSize, ...
                    'LineWidth', obj.FruitBushLineWidth);
                obj.h.FruitBush = [obj.h.FruitBush h];
            end
        end
        
        function updateReloaddFruitBush(obj)
            ReloaddFruitBush = obj.sim.FruitBushHandler.Reloadd;
            for i = 1:length(ReloaddFruitBush)
                h = obj.getPlotHandler(ReloaddFruitBush(i), obj.FruitBush, obj.h.FruitBush);
                set(h, 'Marker', obj.FruitBushReloaddMarker);                
            end
        end
        
        function updateFallouts(obj)
            obj.plotActivatedFallouts();
            obj.deleteObsoletedFallouts();
        end
        
        function plotActivatedFallouts(obj)
            activatedFallouts = obj.sim.falloutsHandler.activated;
            for i = 1:length(activatedFallouts)
                obj.fallouts = [obj.fallouts activatedFallouts(i)];
                edge = activatedFallouts(i).position.edge;
                if(edge.isHorizontal())
                    x1 = activatedFallouts(i).startDistance + edge.startNode.x;
                    x2 = activatedFallouts(i).endDistance + edge.startNode.x;
                    y1 = edge.startNode.y;
                    y2 = y1;
                else
                    x1 = edge.startNode.x;
                    x2 = x1;
                    y1 = activatedFallouts(i).startDistance + edge.startNode.y;
                    y2 = activatedFallouts(i).endDistance + edge.startNode.y;
                end
                h = plot([x1 x2], [y1 y2], obj.falloutsMarker, ...
                    'Color', obj.falloutsColor, ...
                    'LineWidth', obj.falloutsWidth);
                uistack(h, 'bottom');
                uistack(h, 'up', obj.numOfNodes + obj.numOfEdges);
                obj.h.fallouts = [obj.h.fallouts h];
            end
        end
        
        function deleteObsoletedFallouts(obj)
            obsoletedFallouts = obj.sim.falloutsHandler.obsoleted;
            for i = 1:length(obsoletedFallouts)
                h = obj.getPlotHandler(obsoletedFallouts(i), obj.fallouts, obj.h.fallouts);
                delete(h);
            end
        end
        
        function h = getPlotHandler(obj, object, list, hlist)
            h = NaN;
            for i = 1:length(list)
                if(list(i).id == object.id)
                    h = hlist(i);
                end
            end
        end
        
        
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
        
        function [x, y] = getXYFromPosition(obj, position)
            cEdge = position.edge;
            x = -1;
            y = -1;
            if(cEdge.isHorizontal())
                x = position.distance + cEdge.startNode.x;
                y = cEdge.startNode.y;
            elseif(cEdge.isVertical())
                x = cEdge.startNode.x;
                y = position.distance + cEdge.startNode.y;
            end
        end
        
        function turn = getTurn(obj, position, direction)
            edge = position.edge;            
            status = obj.getStatusBitmask(edge, direction);
            
            switch(status)
                case 0
                    turn = '^';
                case 1
                    turn = '>';
                case 2
                    turn = 'v';
                case 3
                    turn = '<';
                case 4
                    turn = 'v';
                case 5
                    turn = '<';
                case 6
                    turn = '^';
                case 7
                    turn = '>';
                otherwise
                    turn = '.';
            end
        end
        
        function status = getStatusBitmask(obj, edge, direction)
            status = 0;
            status = bitset(status, 1, obj.getEdgeTypeBit(edge));
            status = bitset(status, 2, obj.getEdgeTurnBit(edge));
            status = bitset(status, 3, obj.getDirectionBit(direction));
        end
        
        function bitState = getEdgeTypeBit(obj, edge)
            bitState = false;
            if(edge.isHorizontal())
                bitState = true;
            end
        end
        
        function bitState = getEdgeTurnBit(obj, edge)
            bitState = false;
            if(edge.startNode.x < edge.endNode.x | edge.startNode.y < edge.endNode.y)
                bitState = true;
            end
        end
        
        function bitState = getDirectionBit(obj, direction)
            bitState = false;
            if(direction == 1)
                bitState = true;
            end
        end
        
        function printFullLegend(obj)
            xSpacing = 0.2;
            ySpacing = 0.5;
            
            id = 1;
            plot(0, -id*ySpacing, '>', ...
                'MarkerSize', obj.vehMarkerSize, ...
                'LineWidth', obj.vehLineWidth, ...
                'MarkerEdgeColor', obj.vehGroup1EdgeColor);
            text(xSpacing, -id*ySpacing, '- Group 1')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, '>', ...
                'MarkerSize', obj.vehMarkerSize, ...
                'LineWidth', obj.vehLineWidth, ...
                'MarkerEdgeColor', obj.vehGroup2EdgeColor);
            text(xSpacing, -id*ySpacing, '- Group 2')
            
            id = obj.getNextId(id);                      
            plot(0, -id*ySpacing, '>', ...
                'MarkerSize', obj.vehMarkerSize, ...
                'LineWidth', obj.vehLineWidth, ...
                'MarkerFaceColor', obj.vehExploringColor, ...
                'MarkerEdgeColor', obj.vehExploringColor);
            text(xSpacing, -id*ySpacing, '- Exploring')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, '>', ...
                'MarkerSize', obj.vehMarkerSize, ...
                'LineWidth', obj.vehLineWidth, ...
                'MarkerFaceColor', obj.vehWaitingColor, ...
                'MarkerEdgeColor', obj.vehWaitingColor);
            text(xSpacing, -id*ySpacing, '- Waiting')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, '>', ...
                'MarkerSize', obj.vehMarkerSize, ...
                'LineWidth', obj.vehLineWidth, ...
                'MarkerFaceColor', obj.vehCoordinationColor, ...
                'MarkerEdgeColor', obj.vehCoordinationColor);
            text(xSpacing, -id*ySpacing, '- Coordination')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, '>', ...
                'MarkerSize', obj.vehMarkerSize, ...
                'LineWidth', obj.vehLineWidth, ...
                'MarkerFaceColor', obj.vehAssistingColor, ...
                'MarkerEdgeColor', obj.vehAssistingColor);
            text(xSpacing, -id*ySpacing, '- Assisting')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, obj.FruitBushMarker, ...
                    'Color', obj.FruitBushActiveColor, ...
                    'MarkerSize', obj.FruitBushSize, ...
                    'LineWidth', obj.FruitBushLineWidth);
            text(xSpacing, -id*ySpacing, '- FruitBush Active')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, obj.FruitBushReloaddMarker, ...
                    'Color', obj.FruitBushActiveColor, ...
                    'MarkerSize', obj.FruitBushSize, ...
                    'LineWidth', obj.FruitBushLineWidth);
            text(xSpacing, -id*ySpacing, '- FruitBush Reloadd')
            
            id = obj.getNextId(id);            
            x = -0.1;
            y = -id*ySpacing - ySpacing/2;
            w = 0.2;
            h = ySpacing;
            rectangle('Position', [x y w h], ...
                    'FaceColor', obj.falloutsColor, ...
                    'EdgeColor', obj.falloutsColor);
            text(xSpacing, -id*ySpacing, '- ComFallout')
            
            id = obj.getNextId(id);
            id1 = id;
            id = obj.getNextId(id);
            id2 = id;
            
            x = [-0.1 -0.1 0.1 0.1]; 
            y = [-id2*ySpacing -id1*ySpacing -id1*ySpacing -id2*ySpacing];
            c = [1 0 0 1];

            p = patch(x, y, c);
            colormap 'gray';
            text(xSpacing, -abs((id1+id2)/2)*ySpacing, '- Obstacle (severity)');

            
            axis([-0.5 2 -id 0.5]);
            
        end
    end
end