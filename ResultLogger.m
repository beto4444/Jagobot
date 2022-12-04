classdef ResultLogger < handle 
    properties (Constant)
        DIRNAME = 'results';
        SEPARATOR = ';';
    end
    
    properties (SetAccess = immutable)
        baseName;
    end
    
    properties (Access = private)
        vehicles;
        obstaclesHandler;
        FruitBushHandler;
        fileNames;
        cVehData;
    end
    
    methods (Access = public)
        function obj = ResultLogger()
            obj.vehicles = [];
            obj.obstaclesHandler = [];
            obj.FruitBushHandler = [];

            prefix = datestr(clock, 'yyyy_mm_dd_HH_MM_SS');
            fileName = [prefix, '_results_'];
            obj.baseName = [obj.DIRNAME, '/', fileName];
        end
        
        function setPointers(obj, vehicles, obstaclesHandler, FruitBushHandler)
            obj.vehicles = vehicles;
            obj.obstaclesHandler = obstaclesHandler;
            obj.FruitBushHandler = FruitBushHandler;
        end
        
        function createFiles(obj)
            len = length(obj.vehicles);
            obj.fileNames = strings(len, 1);
            for i = 1:length(obj.vehicles)
                obj.fileNames(i) = [obj.baseName, num2str(i), '.csv'];
                obj.createFile(obj.fileNames(i));
            end
        end
        
        function logStep(obj, step)
            for i = 1:length(obj.vehicles)
                obj.logStepForVeh(step, i);
            end
        end
    end
    
    methods (Access = private)
        function createFile(obj, fileName)
            obj.createFolderIfNotExist();
            fclose(fopen(fileName, 'w'));
        end
        
        function createFolderIfNotExist(obj)
            if(exist(obj.DIRNAME) ~= 7)
                mkdir(obj.DIRNAME);
            end
        end
        
        function logStepForVeh(obj, step, vehId)
            if(step == 1 || obj.isDataDifferent(vehId))
                fileId = fopen(obj.fileNames(vehId), 'a');
                obj.addColNamesIfEmptyFile(fileId, vehId);

                logText = '';
                logText = obj.addStepText(logText, step);
                logText = obj.addVehText(logText, vehId);
                logText = [logText '\n'];

                fprintf(fileId, logText);
                fclose(fileId);
            end
        end
        
        function addColNamesIfEmptyFile(obj, fileId, vehId)
            myDir = dir(char(obj.fileNames(vehId)));
            if(myDir.bytes == 0)
                logText = ['step', obj.SEPARATOR];
                logText = obj.addVehCols(logText, vehId);
                logText = [logText, '\n'];
                fprintf(fileId, logText);
            end
        end
        
        function logText = addVehCols(obj, logText, i)
            logText = [logText, 'state-', num2str(i), obj.SEPARATOR, ...
                        'edge-', num2str(i), obj.SEPARATOR, ...
                        'dist-', num2str(i), obj.SEPARATOR, ...
                        'v-', num2str(i), obj.SEPARATOR, ...
                        'dir-', num2str(i), obj.SEPARATOR, ...
                        'rObs-', num2str(i), obj.SEPARATOR, ...
                        'tgtFruitBush-', num2str(i), obj.SEPARATOR, ...
                        'tgtPos-', num2str(i), obj.SEPARATOR, ...
                        'tgtPath-', num2str(i), obj.SEPARATOR];
        end
        
        
        function logText = addStepText(obj, logText, step)
            newText = [num2str(step, '%d'), obj.SEPARATOR];
            logText = [logText, newText];
        end
        
        function logText = addVehText(obj, logText, i)
            obj.cVehData(i).state = obj.vehicles(i).state;
            obj.cVehData(i).edge = obj.vehicles(i).position.edge.id;
            obj.cVehData(i).obstacle = obj.vehicles(i).getRelatedObstacleId();
            obj.cVehData(i).tgtFruitBush = obj.getFruitBushsIds(obj.vehicles(i));
            obj.cVehData(i).tgtPos = obj.vehicles(i).getTargetStr();
            obj.cVehData(i).path = obj.vehicles(i).getPathToTarget();
            
            newText = '';
            newText = [newText, char(obj.cVehData(i).state), ...
            obj.SEPARATOR, ...
            int2str(obj.cVehData(i).edge), ...
            obj.SEPARATOR, ...
            num2str(obj.vehicles(i).position.distance, '%.2f'), ...
            obj.SEPARATOR, ...
            num2str(obj.vehicles(i).vCurrent, '%.2f'), ...
            obj.SEPARATOR, ...
            num2str(obj.vehicles(i).direction, '%+2d'), ...
            obj.SEPARATOR, ...
            num2str(obj.cVehData(i).obstacle, '%d'), ...
            obj.SEPARATOR, ...
            obj.cVehData(i).tgtFruitBush, ...
            obj.SEPARATOR, ...
            obj.cVehData(i).tgtPos, ...
            obj.SEPARATOR, ...
            obj.cVehData(i).path, ...
            obj.SEPARATOR];
            newText = strrep(newText, '.', ',');
            logText = [logText, newText];
        end
        
        function text = getFruitBushsIds(obj, veh)
            text = '';
            if(~isempty(veh.discoveredFruitBush))
                text = int2str(veh.discoveredFruitBush.id);
            elseif(~isempty(veh.FruitBushToAssist))
                text = int2str(veh.FruitBushToAssist.id);
            end
        end
        
        function state = isDataDifferent(obj, i)
            state = false;
            if(obj.cVehData(i).state ~= obj.vehicles(i).state || ...
               obj.cVehData(i).edge ~= obj.vehicles(i).position.edge.id || ...
               ~strcmp(obj.cVehData(i).path, obj.vehicles(i).getPathToTarget()) ||...
               ~strcmp(obj.cVehData(i).obstacle, obj.vehicles(i).getRelatedObstacleId()) || ...
               ~strcmp(obj.cVehData(i).tgtFruitBush, obj.getFruitBushsIds(obj.vehicles(i))) || ...
               ~strcmp(obj.cVehData(i).tgtPos, obj.vehicles(i).getTargetStr()))
               state = true;
            end
        end
    end
end