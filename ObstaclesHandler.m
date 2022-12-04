classdef ObstaclesHandler < handle
    properties (Access = protected) 
        obstacles;
    end
    
    methods (Access = public)
        function obj = ObstaclesHandler()
            obj.obstacles = [];
        end

        function loadFromFile(obj, fileName, tabName, corridors)
            num = xlsread(fileName, tabName);
            for row = 1:size(num, 1)
                obj.obstacles = [obj.obstacles, Obstacle(num(row,:), corridors)];
            end
        end
        
        function obstacles = getObstacles(obj)
            obstacles = obj.obstacles;
        end
    end
end