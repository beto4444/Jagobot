classdef Supervisor < handle     
    properties (SetAccess = immutable)
        corridors;
    end
    
    properties (SetAccess = private)
        mitigationRequested;
        isBestTeam;
    end
    
    properties (Access = private)
        vehicles;
        team;
        superVeh;
    end
    
    properties (Access = public)
    end
    
    methods (Access = public)
        function obj = Supervisor(corridors, vehicles, superVeh)
            obj.corridors = corridors;
            obj.vehicles = vehicles;
            obj.isBestTeam = false;
            obj.team = [];
            obj.mitigationRequested = false;
            obj.superVeh = superVeh;
        end
        
        function status = isTeamReady(obj)
            status = false;
            teamSize = length(obj.team);
            readyVehs = 0;
            for i = 1:teamSize
                if(obj.team(i).FruitBushReached)
                    readyVehs = readyVehs + 1;
                end 
            end
            if(readyVehs == teamSize)
                status = true;
            end
        end
        
        function requestReload(obj)
            obj.mitigationRequested = true;
            for i = 1:length(obj.team)
                obj.team(i).ReloadReq();
            end
            obj.superVeh.ReloadReq();
        end
        
        function requestStop(obj)
            for i = 1:length(obj.team)
                obj.team(i).stopReq();
            end
            obj.superVeh.stopReq();
            obj.superVeh.discoveredFruitBush.stopMitigation();
        end
        
        function isExtended = extendTeam(obj)
            isExtended = false;
            vehs = obj.getInRangeExploringVehicles(obj.superVeh);
            numOfVehsInRange = length(vehs);
            if(numOfVehsInRange > 0)
                numOfAvailableAssistants = obj.computeMaxAvailableAssistants(numOfVehsInRange);
                if(numOfAvailableAssistants > 0)
                    isExtended = true;
                    obj.mitigationRequested = false;
                    assistTable = obj.createAssistTable(vehs);
                    vehIds = obj.getVehicleIds(assistTable, obj.superVeh.id, numOfAvailableAssistants);
                    obj.addToTeam(vehIds, obj.superVeh.discoveredFruitBush);
                end
            end
        end
    end
    
    methods (Access = private)
        function vehs = getInRangeExploringVehicles(obj, supervisor)
            comVector = supervisor.group.comVectorRequest(supervisor);
            vehs = [];
            for i = 1:length(obj.vehicles)
                if(obj.vehicles(i).state == VehState.Exploring & comVector(i))
                    vehs = [vehs obj.vehicles(i)];
                end
            end
        end
        
        function assistTable = createAssistTable(obj, vehs)
            assistTable = num2cell(vehs);
            assistTable = obj.addDistancesToFruitBush(obj.superVeh.discoveredFruitBush.position, assistTable);
        end
        
        function numOfAvailableAssistants = computeMaxAvailableAssistants(obj, numOfVehsInRange)
            numOfRequestedAssistants = obj.superVeh.discoveredFruitBush.maxVehicles - 1 - length(obj.team);
            if(numOfVehsInRange < numOfRequestedAssistants)
                numOfAvailableAssistants = numOfVehsInRange;
            else
                obj.isBestTeam = true;
                numOfAvailableAssistants = numOfRequestedAssistants;
            end
        end
        
        
        function assistTable = addDistancesToFruitBush(obj, FruitBushPosition, assistTable)
            vehsNum = length(assistTable);
            assistTable{2, vehsNum} = [];
            for i = 1:vehsNum
                assistTable{2, i} = obj.corridors.computeDistance(assistTable{1, i}.position, FruitBushPosition);
            end
        end
        
        function ids = getVehicleIds(obj, assistTable, supervisorId, num)
            ids = zeros(1, num);
            [~, idx] = sort([assistTable{2,:}], 'ascend');
            sortedTable = assistTable(:,idx);
            for i = 1:num
                ids(i) = sortedTable{1, i}.id;
            end
        end
        
        function addToTeam(obj, vehIds, targetFruitBush)
            teamSize = length(vehIds);
            for i = 1:teamSize
                obj.vehicles(vehIds(i)).assistReq(targetFruitBush, i);
                obj.team = [obj.team obj.vehicles(vehIds(i))];
            end
        end
    end
end