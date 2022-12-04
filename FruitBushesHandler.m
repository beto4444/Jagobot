classdef FruitBushesHandler < Handlers 
    properties (Access = protected)
        step;
    end
    
    properties (SetAccess = private)
        activated;
        Reloadd;
        numOfFruitBushes;
        FruitBushes;
        algorithm;
    end
    properties(GetAccess=public)
        totalamount;
    end
    
    methods (Access = public)
        function obj = FruitBushesHandler()
            obj.step = 0;
            obj.numOfFruitBushes = 0;
            obj.FruitBushes.inactive = [];
            obj.FruitBushes.active = [];
            obj.FruitBushes.Reloadd = [];
            obj.activated = [];
            obj.Reloadd = [];
            obj.algorithm = Algorithm.Base;
            obj.totalamount=0;
        end
        
        function takeStep(obj)
            obj.step = obj.step + 1;
            obj.updateListsForStep();
            obj.executeMitigation();
            obj.updateTimeOfDiscovery();
        end

        function loadFromFile(obj, fileName, tabName, corridors)
            num = xlsread(fileName, tabName);
            obj.numOfFruitBushes = size(num, 1);
            for row = 1:obj.numOfFruitBushes
                obj.FruitBushes.inactive = [obj.FruitBushes.inactive, FruitBush(num(row,:), corridors)];
                obj.totalamount=obj.totalamount+num(row,5)*10;
            end
        end
        
        function setAlgorithm(obj, algorithm)
            obj.algorithm = algorithm;
        end
        
        function num = getNumOfDiscovered(obj)
            num = length(obj.FruitBushes.Reloadd);
            for i = 1:length(obj.FruitBushes.active)
                cFruitBush = obj.FruitBushes.active(i);
                if(cFruitBush.discovered)
                    num = num + 1;
                end
            end
        end
        
        function num = getNumOfActive(obj)
            num = length(obj.FruitBushes.active);
        end
        
        function obs = getActive(obj, num)
            obs = obj.FruitBushes.active(num);
        end
        
        function obs = getAllActive(obj)
            obs = obj.FruitBushes.active;
        end
        
        function obs = getAllInactive(obj)
            obs = obj.FruitBushes.inactive;
        end
        
        function result = getMitigationStat(obj)
            result = 0;
            for i = 1:length(obj.FruitBushes.Reloadd)
                cFruitBush = obj.FruitBushes.Reloadd(i);
                result = result + cFruitBush.amount;
            end
            for i = 1:length(obj.FruitBushes.active)
                cFruitBush = obj.FruitBushes.active(i);
                progress = 1-(cFruitBush.workTimeToRemove/cFruitBush.initWorkTimeToRemove);
                result = result + cFruitBush.amount*progress;
            end
        end
        
        function result = getMeanOfTimeToDiscover(obj)
            [sumReloadd, numReloadd] = obj.getMeanData(obj.FruitBushes.Reloadd);
            [sumActive, numActive] = obj.getMeanData(obj.FruitBushes.active);
            numAll = numActive + numReloadd;
            if(numAll == 0)
                result = -1;
            else
                result = (sumReloadd + sumActive)/numAll;
            end
        end
        
        function result = getTimeToDiscoverSum(obj)
            [result, ~] = obj.getMeanData(obj.FruitBushes.Reloadd);
            for i = 1:length(obj.FruitBushes.active)
                cFruitBush = obj.FruitBushes.active(i);
                if(cFruitBush.discovered)
                    result = result + cFruitBush.getTimeToDiscover();
                else
                    result = result + (obj.step - cFruitBush.appearanceTime);
                end
            end
        end
        
        function [mitigationSteps, optimalSteps] = getMitigationStats(obj)
            [mStepsReloadd, oStepsReloadd] = obj.getMitigationData(obj.FruitBushes.Reloadd);
            [mStepsActive, oStepsActive] = obj.getMitigationData(obj.FruitBushes.active);
            mitigationSteps = mStepsReloadd + mStepsActive;
            optimalSteps = oStepsReloadd + oStepsActive;
        end
        
        function disp(obj)
            disp('------ Inactive FruitBushes ------');
            for i = 1:length(obj.FruitBushes.inactive)
                obj.FruitBushes.inactive(i).disp();
            end
            disp('------ Active FruitBushes ------');
            for i = 1:length(obj.FruitBushes.active)
                obj.FruitBushes.active(i).disp();
            end
            disp('------ Reloadd FruitBushes ------');
            for i = 1:length(obj.FruitBushes.Reloadd)
                obj.FruitBushes.Reloadd(i).disp();
            end
        end
    end
    
    methods (Access = private)
        function updateListsForStep(obj)
            [obj.FruitBushes.inactive, obj.FruitBushes.active, obj.activated] = obj.updateLists(obj.FruitBushes.inactive, obj.FruitBushes.active, obj.activated, @obj.isAppeared);
            [obj.FruitBushes.active, obj.FruitBushes.Reloadd, obj.Reloadd] = obj.updateLists(obj.FruitBushes.active, obj.FruitBushes.Reloadd, obj.Reloadd, @obj.isReloadd);
        end
        
        function status = isReloadd(obj, obstruction)
            status = obstruction.isReloadd();
        end
        
        function executeMitigation(obj)
            boost = false;
            if(obj.algorithm == Algorithm.Anticipatory)
                boost = true;
            end
            for i = 1:length(obj.FruitBushes.active)
                obj.FruitBushes.active(i).updateWorkTime(boost);
            end
        end
        
        function updateTimeOfDiscovery(obj)
            for i = 1:length(obj.FruitBushes.active)
                cFruitBush = obj.FruitBushes.active(i);
                if(cFruitBush.discovered && cFruitBush.timeOfDiscovery == -1)
                    cFruitBush.timeOfDiscovery = obj.step;
                end
            end 
        end
        
        function [sum, num] = getMeanData(obj, listOfFruitBushes)
            sum = 0;
            num = 0;
            for i = 1:length(listOfFruitBushes)
                cFruitBush = listOfFruitBushes(i);
                if(cFruitBush.discovered)
                    sum = sum + cFruitBush.getTimeToDiscover();
                    num = num + 1;
                end
            end
        end
        
        function [mitigationSteps, optimalSteps] = getMitigationData(obj, listOfFruitBushes)
            mitigationSteps = 0;
            optimalSteps = 0;
            for i = 1:length(listOfFruitBushes)
                cFruitBush = listOfFruitBushes(i);
                mitigationSteps = mitigationSteps + cFruitBush.statMitigationStepsSum;
                optimalSteps = optimalSteps + cFruitBush.statOptimalTeamStepsSum;
            end
        end
    end
end