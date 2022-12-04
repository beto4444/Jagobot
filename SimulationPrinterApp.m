classdef SimulationPrinterApp < handle
    properties (Access = private)
        corridorColor = [1 1 1];
        corridorWidth = 30;
        
        obstacleWidth = 15;
        
        FruitBushesMarker = 'x';
        FruitBushesSize = 12;
        FruitBushesLineWidth = 2;
        FruitBushesActiveColor = [0 0 0];
        FruitBushReloaddMarker = '.';
        
        vehExploringColor = [0 0 0];
        vehCoordinationColor = [1 0 0];
        vehAssistingColor = [1 0 0];
        vehWaitingColor = [1 0 0.04];
        vehRepairingColor = [1 0 0];
        vehGroup1EdgeColor = [0 0 0];
        vehGroup2EdgeColor = [1 0 0];
        vehMarkerSize = 10;
        vehLineWidth = 2;
        
        vehExtendedColor = [0 1 0];
        colorset={[1 0 0] [0 1 0] [0 0 1] [1 1 0] [0 1 1] [1 0 1]};
        falloutsWidth = 1;
        falloutsColor = 'k';
        falloutsMarker = '--';
        
        FruitBushes;
        fallouts;
        
        numOfNodes;
        numOfEdges;
        
        chamgerEdges;
        
        h;
        
        xOffset;
        yOffset
    end
    
    properties (SetAccess = immutable)
        simAxes;
        sim;
        structure;
        chambersIds;
    end
    
    
    methods (Access = public)
        function obj = SimulationPrinterApp(sim, simAxes, chambersIds)
            obj.sim = sim;
            obj.simAxes = simAxes;
            obj.structure = obj.sim.corridors;
            obj.chambersIds = chambersIds;
            obj.FruitBushes = [];
            obj.h.FruitBushes = [];
            obj.fallouts = [];
            obj.h.fallouts = [];
            obj.generateChamberEdges();
        end
        
        function init(obj)
            
            hold(obj.simAxes, 'on');
            obj.simAxes.XLabel.String = 'x length [m]';
            obj.simAxes.YLabel.String = 'y length [m]';
            obj.printEdges();
            obj.printNodes();
            obj.printObstacles();
            %obj.printVehicles();
            obj.printExtendedVehicles();
            obj.numOfNodes = obj.structure.getNumOfNodes();
            obj.numOfEdges = obj.structure.getNumOfEdges();
        end
        
        function update(obj)
%            obj.updateVehicles();
            obj.updateExtendedVehicles();
            obj.updateFruitBushes();
            obj.updateFallouts();
        end
        
        function printLegend(obj)
            axis off;
            hold on;
            
            obj.printFullLegend();
        end
    end
        
        
    methods (Access = private)
        function generateChamberEdges(obj)
            obj.chamgerEdges = [];
            for i = 1:length(obj.chambersIds)
                cNode = obj.structure.getNode(obj.chambersIds(i));
                cAdjEdges = cNode.adjEdges;
                for j = 1:length(cAdjEdges)
                    obj.chamgerEdges = [obj.chamgerEdges, cAdjEdges(j).id];
                end
            end
        end
        
        function printEdges(obj)
            [x,y] = getLinesxy(obj);
            obj.h.corridors = plot(obj.simAxes, x, y, 'LineWidth', obj.corridorWidth, ...
                'Color', obj.corridorColor);
            obj.xOffset = max(max(x))*0.1;
            obj.yOffset = max(max(y))*0.1;
             obj.simAxes.XLim = [min(min(x)) - obj.xOffset, max(max(x)) + obj.xOffset];
             obj.simAxes.YLim = [min(min(y)) - obj.yOffset, max(max(y)) + obj.yOffset];
        end
        
        function printNodes(obj)
            for nodeId = 1:obj.structure.getNumOfNodes()
                markerSize = 30;
                if ismember(nodeId, obj.chambersIds)
                    markerSize = 50;
                end
                h = plot(obj.simAxes, obj.structure.getNode(nodeId).x, obj.structure.getNode(nodeId).y,...
                    '.', 'MarkerSize', markerSize, 'Color', obj.corridorColor);
            end
        end
        
        function printVehicles(obj)
            for i = 1:length(obj.sim.vehicleGroups)
                obj.printGroup(obj.sim.vehicleGroups(i), i);
            end
        end
        
        function printExtendedVehicles(obj)
            obj.h.group = cell(1,length(obj.sim.vehicleGroups));
            for i = 1:length(obj.sim.vehicleGroups)
                obj.printExtendedGroup(obj.sim.vehicleGroups(i), i);
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
                obj.h.group(groupId).vehicles(i) = plot(obj.simAxes, vehx, vehy, symbol, ...
                    'MarkerSize', obj.vehMarkerSize, ...
                    'LineWidth', obj.vehLineWidth, ...
                    'MarkerFaceColor', obj.vehExploringColor, ...
                    'MarkerEdgeColor', groupColor);
            end
        end
        
        function printExtendedGroup(obj, group, groupId)
            width = 75;
            height = 20;
            rCircle = 0.5*height;
            xOffsetCircle = width/12;
            yOffsetCircle = height/4;
            
            obj.vehExtendedColor=obj.colorset{groupId};
            obj.h.group{groupId} = cell(1, group.numOfVehicles);
            
            
            obj.h.extVehicle = cell(1,20);
            for i = 1:group.numOfVehicles
                obj.h.group{groupId}{i} = cell(1,4);
                
                [x, y] = obj.getXYFromPosition(group.vehicles(i).position);
                x = x - width/2;
                obj.h.group{groupId}{i}{1} = rectangle(obj.simAxes, ...
                    'Position', [x y width height], 'Curvature', 1, ...
                    'EdgeColor', obj.vehExtendedColor);
                %left 
                obj.h.group{groupId}{i}{2} = rectangle(obj.simAxes, ...
                'Position', [x + xOffsetCircle, y + yOffsetCircle, ...
                rCircle, rCircle], 'Curvature', [1, 1], 'FaceColor', obj.vehExtendedColor, ...
                    'EdgeColor', obj.vehExtendedColor);
                %right
                obj.h.group{groupId}{i}{3} = rectangle(obj.simAxes, ...
                    'Position', [x + width - xOffsetCircle - rCircle, y + yOffsetCircle, ...
                    rCircle, rCircle], 'Curvature', [1, 1], 'FaceColor', obj.vehExtendedColor, ...
                    'EdgeColor', obj.vehExtendedColor);
                %rectangle
                obj.h.group{groupId}{i}{4} = rectangle(obj.simAxes, ...
                    'Position', [x + width/4, y + height, width/2, height/2], 'Curvature', 0.1, ...
                    'EdgeColor', obj.vehExtendedColor);
%                 %antenna
%                 obj.h.group{groupId}{i}{5} = plot(obj.simAxes, ...
%                     [x + 3*width/4 - rCircle, x + 3*width/4], ...
%                     [y + 3*height/2, y + 3*height/2 + 2*rCircle], 'k');
            end
        end
        
        function printObstacles(obj)
            inactiveObstacles = obj.sim.obstaclesHandler.getObstacles();
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
                obj.h.obstacles(i) = plot(obj.simAxes, [x1 x2], [y1 y2], 'Color', color, ...
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
        
        function updateExtendedVehicles(obj)
            width = 75;
            height = 20;
            rCircle = 0.5*height;
            xOffsetCircle = width/12;
            yOffsetCircle = height/4;
            
            for gr = 1:length(obj.h.group)
                group = obj.sim.vehicleGroups(gr);
                for i = 1:length(obj.h.group{gr})
                    [x, y] = obj.getXYFromPosition(group.vehicles(i).position);
                    x = x - width/2;
                    set(obj.h.group{gr}{i}{1}, 'Position', ...
                        [x y width height]);
                    set(obj.h.group{gr}{i}{2}, 'Position', ...
                        [x + xOffsetCircle, y + yOffsetCircle, rCircle, rCircle]);
                    set(obj.h.group{gr}{i}{3}, 'Position', ...
                         [x + width - xOffsetCircle - rCircle, y + yOffsetCircle, ...
                    rCircle, rCircle]);
                    set(obj.h.group{gr}{i}{4}, 'Position', ...
                        [x + width/4, y + height, width/2, height/2]);
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
                case VehState.Repairing
                    color = obj.vehRepairingColor;
                otherwise
                    color = obj.vehExploringColor;
            end
        end
        
        function updateFruitBushes(obj)
            obj.plotActivatedFruitBushes();
            obj.updateReloaddFruitBushes();
        end
        
        function plotActivatedFruitBushes(obj)
            width = obj.xOffset*3;
            height = obj.yOffset*2;
            
            activatedFruitBushes = obj.sim.FruitBushesHandler.activated;
            for i = 1:length(activatedFruitBushes)
                obj.FruitBushes = [obj.FruitBushes activatedFruitBushes(i)];
                [x, y] = obj.getXYFromPosition(activatedFruitBushes(i).position);
                sizeofmarker=activatedFruitBushes(i).amount;

                if ismember(activatedFruitBushes(i).position.edge.id, obj.chamgerEdges)
                    h = rectangle(obj.simAxes, ...
                        'Position', [x - width/2, y - height/2, width, height], ...
                        'Curvature', 1, ... 
                        'LineStyle', ':', ...
                        'LineWidth', 5, ...
                        'EdgeColor', [0.45,0,0]);
                else
                    if(activatedFruitBushes(i).side==0)
                    h = plot(obj.simAxes, x-50, y, 'o', ...
                        'Color', 'r', ...
                        'MarkerSize', obj.FruitBushesSize*sizeofmarker, ...
                        'MarkerFaceColor','r',...
                        'LineWidth', obj.FruitBushesLineWidth);
                    else
                     h = plot(obj.simAxes, x+50, y, 'o', ...
                        'Color', 'r', ...
                        'MarkerSize', obj.FruitBushesSize*sizeofmarker, ...
                        'MarkerFaceColor','r',...
                        'LineWidth', obj.FruitBushesLineWidth);   
                    end

                end

                obj.h.FruitBushes = [obj.h.FruitBushes h];
            end
        end
        
        function updateReloaddFruitBushes(obj)
            ReloaddFruitBushes = obj.sim.FruitBushesHandler.Reloadd;
            for i = 1:length(ReloaddFruitBushes)
                h = obj.getPlotHandler(ReloaddFruitBushes(i), obj.FruitBushes, obj.h.FruitBushes);
                if ismember(ReloaddFruitBushes(i).position.edge.id, obj.chamgerEdges)
                    set(h, 'EdgeColor', [0.85, 0.41, 0.14]);                
                else
                    set(h, 'Marker', obj.FruitBushReloaddMarker);                
                end
            end
        end
        
        function updateFallouts(obj)
            obj.plotActivatedFallouts();
            obj.deleteObsoletedFallouts();
        end
        
        function plotActivatedFallouts(obj)
            offsetX = 0.04*obj.structure.maxX;
            offsetY = 0.04*obj.structure.maxY;
            activatedFallouts = obj.sim.falloutsHandler.activated;
            for i = 1:length(activatedFallouts)
                if(activatedFallouts(i).id < 0)
                    continue;
                end
                obj.fallouts = [obj.fallouts activatedFallouts(i)];
                edge = activatedFallouts(i).position.edge;
                if(edge.isHorizontal())
                    x1 = activatedFallouts(i).startDistance + edge.startNode.x;
                    x2 = activatedFallouts(i).endDistance + edge.startNode.x;
                    y1 = edge.startNode.y - offsetY;
                    y2 = edge.startNode.y + offsetY;
                else
                    x1 = edge.startNode.x - offsetX;
                    x2 = edge.startNode.x + offsetX;
                    y1 = activatedFallouts(i).startDistance + edge.startNode.y;
                    y2 = activatedFallouts(i).endDistance + edge.startNode.y;
                end
                h = plot(obj.simAxes, ...
                    [x1 x2 x2 x1 x1], ...
                    [y1 y1 y2 y2 y1], ...
                    obj.falloutsMarker, ...
                    'Color', obj.falloutsColor, ...
                    'LineWidth', obj.falloutsWidth);
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
            plot(0, -id*ySpacing, obj.FruitBushesMarker, ...
                    'Color', obj.FruitBushesActiveColor, ...
                    'MarkerSize', obj.FruitBushesSize, ...
                    'LineWidth', obj.FruitBushesLineWidth);
            text(xSpacing, -id*ySpacing, '- FruitBush Active')
            
            id = obj.getNextId(id);            
            plot(0, -id*ySpacing, obj.FruitBushReloaddMarker, ...
                    'Color', obj.FruitBushesActiveColor, ...
                    'MarkerSize', obj.FruitBushesSize, ...
                    'LineWidth', obj.FruitBushesLineWidth);
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