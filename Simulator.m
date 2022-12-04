classdef Simulator < handle
    properties (Constant)
        initVehDistanceMin = 10;
        initVehDistanceMax = 20;
    end
    
    properties (Access = private)
        resultLogger;
    end
    
    properties (SetAccess = private)
        corridors;
        cycleTime;
        step;
        g;
        vehicleGroups;
        FruitBushesHandler;
        obstaclesHandler;
        falloutsHandler;
        dataFileName;
        isLoggingEnabled;
        algorithm;
        vehsPerGroup;
        
        statNumOfRepairs;
        statNumOfKm;
        statMeanTimeToDiscoverFruitBushes;
        statMitigationStepsSumForFruitBushes;
        statOptimalTeamStepsSumForFruitBushes;
        stats;
    end
    
    
    properties (Access = public)
        FruitBushesInMitigation;
    end
    
    methods (Access = public)
        function obj = Simulator()
            obj.vehsPerGroup = [];
            obj.vehicleGroups = [];
            obj.FruitBushesInMitigation = [];
            
            obj.falloutsHandler = FalloutsHandler();
            obj.obstaclesHandler = ObstaclesHandler();
            obj.FruitBushesHandler = FruitBushesHandler();
            
            obj.resultLogger = ResultLogger();
        end

        function initSimulation(obj, corridors, vehsPerGroup, comRange, ...
                fileName, cycleTime, isLoggingEnabled, algorithm)
            
            obj.setAlgorithm(algorithm);
            obj.dataFileName = fileName;
            obj.corridors = corridors;
            obj.vehsPerGroup = vehsPerGroup;
            obj.cycleTime = cycleTime;
            obj.isLoggingEnabled = isLoggingEnabled;
        
            obj.step = 0;
            obj.initVehicleGroups();
            
            if(comRange == -1)
                obj.falloutsHandler.loadFromFile(obj.dataFileName, 'Fallouts', obj.corridors);
            else
                obj.falloutsHandler.createFallots(comRange, obj.corridors);
            end
            obj.obstaclesHandler.loadFromFile(obj.dataFileName, 'Obstacles', obj.corridors);
            obj.FruitBushesHandler.loadFromFile(obj.dataFileName, 'FruitBushes', obj.corridors);
            obj.FruitBushesHandler.setAlgorithm(obj.algorithm);
            
            if(obj.isLoggingEnabled)
                obj.initLogger();
            end
            obj.initStats();
        end 
        
        function simulate(obj, numOfSteps)
            for step = 1:numOfSteps
                if(obj.isFinished())
                    break;
                end
                if(obj.step == 1)
                    obj.activateObstacles();
                end
                obj.takeStep();
                obj.handleFruitBushesChanges();
                obj.handleComFalloutsChanges();
                obj.simulateVehicles();
                if(obj.isLoggingEnabled)
                    obj.resultLogger.logStep(obj.step);
                end
                if(mod(obj.step, 10) == 0)
                    obj.saveStats(obj.step/10);
                end
            end
        end
        
        function updateStats(obj)
            obj.getFinalStatistics();
        end
        
        function data = getResultData(obj)
            row = 1;
            data = cell(sum(obj.vehsPerGroup), 10);
            for group = 1:length(obj.vehicleGroups)
                cGroup = obj.vehicleGroups(group);
                for veh = 1:length(cGroup.vehicles)
                    cVeh = cGroup.vehicles(veh);
                    data(row, 1) = {[int2str(cGroup.id), '-', int2str(cVeh.id)]};
                    data(row, 2) = {[int2str(cVeh.position.edge.id), '-', num2str(cVeh.position.distance, '%.0f')]};
                    data(row, 3) = {cVeh.vCurrent};
                    data(row, 4) = {int2str(cVeh.direction)};
                    data(row, 5) = {cVeh.energyConsumption};
                    data(row, 6) = {cVeh.damage};
                    data(row, 7) = {char(cVeh.state)};
                    data(row, 8) = {int2str(cVeh.statNumOfRepairs)};
                    data(row, 9) = {cVeh.statNumOfKm};
                    row = row + 1;
                end
            end
        end
        
        function status = isFinished(obj)
            status = false;
            if(obj.step >= obj.cycleTime)
                status = true;
            end
        end

        function damages = getDamagesMatrix(obj)
            vehSum = sum(obj.vehsPerGroup);
            damages = zeros(vehSum, 1);
            
            for vehId = 1:vehSum
                if(vehId <= obj.vehsPerGroup(1))
                    damages(vehId) = obj.vehicleGroups(1).vehicles(vehId).damage;
                else
                    newVehId = vehId - obj.vehsPerGroup(1);
                    damages(vehId) = obj.vehicleGroups(2).vehicles(newVehId).damage;
                end
            end
        end
    end
    
    methods (Access = private)
        function setAlgorithm(obj, algorithm)
            if(algorithm == 1)
                obj.algorithm = Algorithm.Anticipatory;
            else
                obj.algorithm = Algorithm.Base;
            end
        end
        
        function initStats(obj)
            obj.g = zeros(1, 3);
            obj.statNumOfRepairs = 0;
            obj.statNumOfKm = 0;
            obj.statMeanTimeToDiscoverFruitBushes = -1;
            obj.statMitigationStepsSumForFruitBushes = 0;
            obj.statOptimalTeamStepsSumForFruitBushes = 0;    
            obj.stats.discoveredPercent = 0;
            obj.stats.ReloaddPercent = 0;
            obj.stats.timeToDiscoverSum = 0;
            obj.stats.mitigationTimePerSeverity = 0;
            obj.stats.energyConsumption = 0;
            
            listLen = obj.cycleTime/10;
            
            obj.stats.repairsNumList = zeros(listLen, 1);
            obj.stats.kmNumList = zeros(listLen, 1);
            obj.stats.avgMitTList = zeros(listLen, 1);
            obj.stats.TtTList = zeros(listLen, 1);
            obj.stats.energyList = zeros(listLen, 1);
            obj.stats.damagesList = zeros(listLen, 1);
            obj.stats.cwOptList = zeros(listLen, 1);
            obj.stats.mitSeverityList = zeros(listLen, 1);
        end
        

        
        function initVehicleGroups(obj)
            for i = 1:length(obj.vehsPerGroup)
                if(obj.vehsPerGroup(i) == 0)
                    continue;
                end
                newGroup = VehicleGroup(i, obj.vehsPerGroup(i), obj.corridors, obj.algorithm, obj);
                newGroup.init();
                obj.vehicleGroups = [obj.vehicleGroups, newGroup];
            end
        end
    
        function initLogger(obj)
            vehicles = [];
            for i = 1:length(obj.vehicleGroups)
                vehicles = [vehicles, obj.vehicleGroups(i).vehicles];
            end
            obj.resultLogger.setPointers(vehicles, obj.obstaclesHandler, obj.FruitBushesHandler);
            obj.resultLogger.createFiles();
        end
    
        function takeStep(obj)
            obj.step = obj.step + 1;
            obj.falloutsHandler.takeStep();
            obj.FruitBushesHandler.takeStep();
        end
        
        function handleComFalloutsChanges(obj)
            activated = obj.falloutsHandler.activated;
            obsoleted = obj.falloutsHandler.obsoleted;

            for i = 1:length(obj.vehicleGroups)
                obj.vehicleGroups(i).handleComFalloutsUpdates(activated, obsoleted);
            end
        end

        function activateObstacles(obj)
            activated = obj.obstaclesHandler.getObstacles();
            for i = 1:length(obj.vehicleGroups)
                obj.vehicleGroups(i).activateObstacles(activated);
            end
        end
        
        function handleFruitBushesChanges(obj)
            active = obj.FruitBushesHandler.getAllActive();
            Reloadd = obj.FruitBushesHandler.Reloadd;

            for i = 1:length(obj.vehicleGroups)
                obj.vehicleGroups(i).handleFruitBushesUpdates(active, Reloadd);
            end
        end

        function simulateVehicles(obj)
            for i = 1:length(obj.vehicleGroups)
                obj.vehicleGroups(i).executeAction(obj.step);
            end
        end
        
        function dispVehicles(obj)
            for i = 1:length(obj.vehicleGroups)
                obj.vehicleGroups(i).disp();
            end
        end
        
        function updateG(obj)
            obj.updateG1();
            obj.updateG3();
        end
        
        function updateG1(obj)
            obj.g(1) = obj.FruitBushesHandler.getMitigationStat();
        end
        
        function updateG3(obj)
            damages = 0;
            for i = 1:length(obj.vehicleGroups)
                damages = damages + obj.vehicleGroups(i).getSumOfDmg();
            end
            obj.g(3) = damages;
        end
        
        function getFinalStatistics(obj)
            obj.updateG();
            for i = 1:length(obj.vehicleGroups)
                for j = 1:length(obj.vehicleGroups(i).vehicles)
                    cVeh = obj.vehicleGroups(i).vehicles(j);
                    obj.statNumOfRepairs = obj.statNumOfRepairs + cVeh.statNumOfRepairs;
                    obj.statNumOfKm = obj.statNumOfKm + cVeh.statNumOfKm;
                    obj.stats.energyConsumption = obj.stats.energyConsumption + cVeh.energyConsumption;
                end
            end
            obj.statMeanTimeToDiscoverFruitBushes = obj.FruitBushesHandler.getMeanOfTimeToDiscover();
            [obj.statMitigationStepsSumForFruitBushes, obj.statOptimalTeamStepsSumForFruitBushes] = obj.FruitBushesHandler.getMitigationStats();
            obj.stats.ReloaddPercent = 100*length(obj.FruitBushesHandler.FruitBushes.Reloadd)/obj.FruitBushesHandler.numOfFruitBushes;
            obj.stats.discoveredPercent = 100*obj.FruitBushesHandler.getNumOfDiscovered()/obj.FruitBushesHandler.numOfFruitBushes;
            obj.stats.timeToDiscoverSum = obj.FruitBushesHandler.getTimeToDiscoverSum();
            obj.stats.mitigationTimePerSeverity = obj.statMitigationStepsSumForFruitBushes/obj.g(1);
        end
        
        function saveStats(obj, i)
            obj.updateG();
            obj.stats.repairsNumList(i) = obj.getSumOfRepairs();
            obj.stats.kmNumList(i) = obj.getSumOfkm();
            obj.stats.energyList(i) = obj.getSumOfEnergy();
            obj.stats.damagesList(i) = obj.getSumOfDmg();
            obj.stats.mitSeverityList(i) = obj.g(1);
            
            if(obj.g(1) ~= 0)
                obj.stats.avgMitTList(i) = obj.statMitigationStepsSumForFruitBushes/obj.g(1);
            else
                obj.stats.avgMitTList(i) = 0;
            end
            obj.stats.TtTList(i) = obj.FruitBushesHandler.getTimeToDiscoverSum();
            
            [obj.statMitigationStepsSumForFruitBushes, obj.statOptimalTeamStepsSumForFruitBushes] = obj.FruitBushesHandler.getMitigationStats();
            obj.stats.cwOptList(i) = obj.statOptimalTeamStepsSumForFruitBushes/obj.statMitigationStepsSumForFruitBushes;
        end
        
        function repairs = getSumOfRepairs(obj)
            repairs = 0;
            for i = 1:length(obj.vehicleGroups)
                repairs = repairs + obj.vehicleGroups(i).getSumOfRepairs();
            end
        end
        
        function dmg = getSumOfDmg(obj)
            dmg = 0;
            for i = 1:length(obj.vehicleGroups)
                dmg = dmg + obj.vehicleGroups(i).getSumOfDmg();
            end
        end
        
        function km = getSumOfkm(obj)
            km = 0;
            for i = 1:length(obj.vehicleGroups)
                km = km + obj.vehicleGroups(i).getSumOfkm();
            end
        end
        
        function energy = getSumOfEnergy(obj)
            energy = 0;
            for i = 1:length(obj.vehicleGroups)
                energy = energy + obj.vehicleGroups(i).getSumOfEnergy();
            end
        end
        

    end
    
end