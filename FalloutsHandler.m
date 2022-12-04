classdef FalloutsHandler < Handlers 
    properties (Access = protected)
        step;
        fallouts;
    end
    
    properties (SetAccess = private)
        activated;
        obsoleted;
    end
    
    methods (Access = public)
        function obj = FalloutsHandler()
            obj.step = 0;
            obj.fallouts.inactive = [];
            obj.fallouts.active = [];
            obj.fallouts.obsoleted = [];
            obj.activated = [];
            obj.obsoleted = [];
        end
        
        function takeStep(obj)
            obj.step = obj.step + 1;
            obj.updateListsForStep();
        end

        function loadFromFile(obj, fileName, tabName, corridors)
            num = xlsread(fileName, tabName);
            for row = 1:size(num, 1)
                obj.fallouts.inactive = [obj.fallouts.inactive, ComFallout(num(row,:), corridors)];
            end
        end
        
        function createFallots(obj, comRange, corridors)
            data = obj.generateFallouts(comRange, corridors);
            for row = 1:size(data, 1)
                obj.fallouts.inactive = [obj.fallouts.inactive, ComFallout(data(row,:), corridors)];
            end
        end
        
        function disp(obj)
            for i = 1:length(obj.fallouts.inactive)
                obj.fallouts.inactive(i).disp();
            end
        end
    end
    
    methods (Access = private)
        function updateListsForStep(obj)
            [obj.fallouts.inactive, obj.fallouts.active, obj.activated] = obj.updateLists(obj.fallouts.inactive, obj.fallouts.active, obj.activated, @obj.isAppeared);
            [obj.fallouts.active, obj.fallouts.obsoleted, obj.obsoleted] = obj.updateLists(obj.fallouts.active, obj.fallouts.obsoleted, obj.obsoleted, @obj.isDisappeared);
        end
        
        function status = isDisappeared(obj, fallout)
            status = false;
            if(fallout.appearanceTime + fallout.duration <= obj.step)
                status = true;
            end
        end
        
        function data = generateFallouts(obj, comRange, corridors)
            numOfEdges = corridors.getNumOfEdges();
            data = zeros(numOfEdges, 7);
            for i = 1:numOfEdges
                cEdge = corridors.getEdge(i);
                data(i, 1) = -i;
                data(i, 2) = i;
                data(i, 3) = cEdge.distance/2;
                data(i, 4) = cEdge.distance + 10;
                data(i, 5) = 0;
                data(i, 6) = 30000;
                data(i, 7) = comRange;
            end
        end
    end
end