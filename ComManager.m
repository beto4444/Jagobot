classdef ComManager < handle
    properties (Constant)
        MAXCOMRANGE = 300;
    end

    properties (SetAccess = immutable)
        corridors;
        vehicles;
    end

    properties (Access = private)
        comMatrix;
        fallouts;
    end
    
    methods (Access = public)
        function obj = ComManager(corridors, vehicles)
            obj.corridors = corridors;
            obj.vehicles = vehicles;
            obj.fallouts = [];
        end

        function comMatrix = generateComMatrix(obj, distMatrix)
            obj.comMatrix = distMatrix;
            comVector = obj.generateComVector();
            obj.convertToComMatrix(comVector);
            comMatrix = obj.comMatrix;
        end
        
        function addFallouts(obj, fallouts)
            for i = 1:length(fallouts)
                obj.fallouts = [obj.fallouts fallouts(i)];
            end
        end
        
        function removeFallouts(obj, fallouts)
            index = 1;
            while index <= length(obj.fallouts)
                for j = 1:length(fallouts)
                    if(fallouts(j).id == obj.fallouts(index).id)
                        obj.fallouts(index) = [];
                        continue;
                    end
                end
                index = index + 1;
            end
        end
    end
    
    methods (Access = private)
        function comVector = generateComVector(obj)
            vehPositions = getVehiclesPosition(obj);
            comVector = zeros(1, length(vehPositions));
            for veh = 1:length(vehPositions)
                for fallout = 1:length(obj.fallouts)
                    if(obj.fallouts(fallout).isInRange(vehPositions{veh}))
                        comVector(veh) = obj.fallouts(fallout).comRange;
                    end
                end
                if(comVector(veh) == 0)
                    comVector(veh) = obj.MAXCOMRANGE;
                end
            end
        end
        
        function convertToComMatrix(obj, comVector)
            for row = 1:length(obj.comMatrix)
                for col = row:length(obj.comMatrix)
                    comRange = min(comVector(col), comVector(row));
                    if(obj.comMatrix(row, col) <= comRange)
                        obj.comMatrix(row, col) = true;
                        obj.comMatrix(col, row) = true;
                    else
                        obj.comMatrix(row, col) = false;
                        obj.comMatrix(col, row) = false;
                    end
                end
            end
        end
        
        function vehPositions = getVehiclesPosition(obj)
            vehPositions = cell(1, length(obj.vehicles));
            for i = 1:length(obj.vehicles)
                vehPositions{i} = obj.vehicles(i).position;
            end
        end
    end
end