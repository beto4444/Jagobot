classdef FruitBushPrinter < handle 
    properties (Access = private)
        FruitBush;
        numOfVehicles;
    end
    
    properties (SetAccess = immutable)
        axes;
    end
    
    
    methods (Access = public)
        function obj = FruitBushPrinter(axes)
            obj.axes = axes;
            obj.numOfVehicles = 0;
            
            hold(obj.axes, 'on');

            obj.printWall();
            %obj.printVehicle([15, 10], 'farMitigation');
            %obj.printVehicle([35, 20], 'sensor');
            %obj.printVehicle([70, 5], 'methaneSensor');
            
            obj.axes.XLim = [0, 100];
            obj.axes.YLim = [0, 50];
        end
        
        function addVehicle(obj)
            xPos = obj.numOfVehicles*20 + 10;
            obj.printVehicle([xPos, 10], 'closeMitigation');
            obj.numOfVehicles = obj.numOfVehicles + 1;
        end
    end
        
        
    methods (Access = private)
        function printWall(obj)
            wallColor = [0.3 0.3 0.3];
            rectangle(obj.axes, 'Position', [0 30 100 20], ...
                'FaceColor', wallColor, ...
            'EdgeColor', wallColor );
        end
        
        function printVehicle(obj, pos, type)
            width = 14;
            height = 4;
            x = pos(1);
            y = pos(2);
            
            rectangle(obj.axes, 'Position', [x y width height], 'Curvature', 1);
            %left 
            rectangle(obj.axes, 'Position', [x + 1, y + 1, 2, 2], 'Curvature', [1, 1], 'FaceColor', 'k');
            %right
            rectangle(obj.axes, 'Position', [x + width - 3, y + 1, 2, 2], 'Curvature', [1, 1], 'FaceColor', 'k');
            %rectangle
            rectangle(obj.axes, 'Position', [x + width/4, y + height, width/2, height/2], 'Curvature', 0.1);
            %antenna
            plot(obj.axes, [x + 3*width/4 - 2, x + 3*width/4], ...
                [y + 3*height/2, y + 3*height/2 + 5], 'k',...
                'LineWidth', 2);
            
            switch type
                case 'farMitigation'
                     plot(obj.axes, [x + width/3, x - 10, x + 10], ...
                        [y + 3*height/2, y + 30, y + 60], 'k',...
                        'LineWidth', 4);
                    
                case 'closeMitigation'
                     plot(obj.axes, [x + width/3, x + 8, x + 3], ...
                        [y + 3*height/2, y + 15, y + 25], 'k',...
                        'LineWidth', 4);
                    
               case 'sensor'
                     plot(obj.axes, [x + width/3, x + width/3], ...
                        [y + 3*height/2, y + 3*height/2 + 8], 'k',...
                        'LineWidth', 3);
                    rectangle(obj.axes, 'Position', [x + width/3 - 2, y + 3*height/2 + 8, 4, 4], ...
                        'Curvature', [1, 1], 'LineWidth', 2);
               
                case 'methaneSensor'
                     plot(obj.axes, [x + width/3, x + width/3], ...
                        [y + 3*height/2, y + 3*height/2 + 8], 'k',...
                        'LineWidth', 3);
                    rectangle(obj.axes, 'Position', [x + width/3 - 4, y + 3*height/2 + 8, 8, 2], ...
                        'Curvature', [1, 0.5], 'LineWidth', 2);
            end
                    
            
        end
    end
end