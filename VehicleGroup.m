classdef VehicleGroup < handle 
    properties (Constant)
        INIT_VEH_DISTANCE_MIN = 10;
        INIT_VEH_DISTANCE_MAX = 20;
    end
    
    properties (SetAccess = immutable)
        numOfVehicles;
        corridors;
        id;
    end
    
    properties (SetAccess = private)
        vehicles;
        tgtId;
        algorithm;
        sim;
    end
    
    properties (Access = private) 
        comManager;
        exploringAlg;
    end
    
    properties (Access = public)
        distMatrix;
        comMatrix;
    end
    
    methods (Access = public)
        function obj = VehicleGroup(groupId, numOfVehicles, corridors, algorithm, sim)
            obj.numOfVehicles = numOfVehicles;
            obj.corridors = corridors;
            obj.comManager = [];
            obj.id = groupId;
            obj.distMatrix = [];
            obj.comMatrix = [];
            obj.tgtId = 1;
            obj.exploringAlg = [];
            obj.algorithm = algorithm;
            obj.sim = sim;
        end
        
        function init(obj)
            for i = 1:obj.numOfVehicles
                obj.vehicles = [obj.vehicles, Vehicle(i, obj.corridors, obj, i)];
            end
            obj.setInitPositions(obj.id);
            obj.setInitDirections();
            
            obj.comManager = ComManager(obj.corridors, obj.vehicles);
            obj.exploringAlg = ExploringAlgorithm(obj.corridors, obj.vehicles);
        end
        
        function activateObstacles(obj, activated)
            for veh = 1:obj.numOfVehicles
                obj.vehicles(veh).addKnownObstacles(activated);
            end
        end
        
        function handleFruitBushesUpdates(obj, active, Reloadd)


            %optimalization here

            for veh = 1:obj.numOfVehicles
                for FruitBush = 1:length(active)
                    if(obj.isDiscovered(obj.vehicles(veh), active(FruitBush)))
                        n = mod(FruitBush, obj.numOfVehicles);
                        obj.vehicles(n).addDiscoveredFruitBush(active(FruitBush));
                        obj.sim.FruitBushesInMitigation = [obj.sim.FruitBushesInMitigation, active(FruitBush)];
                        continue;
                    end
                end
                if(~isempty(Reloadd))
                    obj.vehicles(veh).handleReloaddFruitBush(Reloadd);
                end
            end
        end
        
        function handleComFalloutsUpdates(obj, activated, obsoleted)
            obj.comManager.addFallouts(activated);
            obj.comManager.removeFallouts(obsoleted);
        end
        
        function executeAction(obj, step)
            obj.generateDistMatrix();
            obj.comMatrix = obj.comManager.generateComMatrix(obj.distMatrix);
            obj.exploringAlg.updateTgtPositions(step);
            for i = 1:obj.numOfVehicles
                obj.vehicles(i).executeAction(step);
            end
        end
        
        function num = getNumOfExploringVehicles(obj, comVector)
            num = 0;
            for i = 1:obj.numOfVehicles
                if(obj.vehicles(i).state == VehState.Exploring & comVector(i))
                    num = num + 1;
                end
            end
        end
        
        function distVector = getDistancesToFruitBush(obj, FruitBushPosition)
            distVector = zeros(1, obj.numOfVehicles);
            for i = 1:obj.numOfVehicles
                distVector(i) = obj.corridors.computeDistance(obj.vehicles(i).position, FruitBushPosition);
            end
        end
        
        function status = supervisionRightsRequest(obj, vehicle)
%             status = false;
%             comVector = obj.comMatrix(vehicle.id, :);
%             if(obj.getNumOfExploringVehicles(comVector) >= 1)
%                 status = true;
%             end
              status = true;
        end
        
        function supervisor = getSupervisionRights(obj, superVeh)
            supervisor = Supervisor(obj.corridors, obj.vehicles, superVeh);
        end
        
        function dmg = getSumOfDmg(obj)
            dmg = 0;
            for i = 1:obj.numOfVehicles
                dmg = dmg + obj.vehicles(i).damageOverall + obj.vehicles(i).damage;
            end
        end
              
        function repairs = getSumOfRepairs(obj)
            repairs = 0;
            for i = 1:obj.numOfVehicles
                repairs = repairs + obj.vehicles(i).statNumOfRepairs;
            end
        end
        
        function km = getSumOfkm(obj)
            km = 0;
            for i = 1:obj.numOfVehicles
                km = km + obj.vehicles(i).statNumOfKm;
            end
        end
        
        function energy = getSumOfEnergy(obj)
            energy = 0;
            for i = 1:obj.numOfVehicles
                energy = energy + obj.vehicles(i).energyConsumption;
            end
        end
        
        function comVector = comVectorRequest(obj, vehicle)
            comVector = obj.comMatrix(vehicle.id, :);
        end
        
        function disp(obj)
            disp([repmat('-', 1, 30), ' Group ', num2str(obj.id), ' ', repmat('-', 1, 30)]);
            for i = 1:obj.numOfVehicles
                obj.vehicles(i).disp();
            end
            disp([repmat('-', 1, 28), ' End of group ', repmat('-', 1, 28),]);
        end
    end
    
    methods (Access = private)
        function setInitPositions(obj, n)
            %entranceNodeId = obj.corridors.entranceNodeId;
            entranceNodeId=1+(n-1)*3;
            entranceNode = obj.corridors.getNode(entranceNodeId);
            numOfEdges = entranceNode.getNumOfAdjEdges();
            
            selectedEdgeId = mod(obj.id - 1, numOfEdges) + 1;
            selectedEdge = entranceNode.getAdjEdge(selectedEdgeId);
            
            distSum = 0;
            for veh = 1:obj.numOfVehicles
                distToVeh = randi([obj.INIT_VEH_DISTANCE_MIN, obj.INIT_VEH_DISTANCE_MAX], 1, 1);
                distSum = distSum + distToVeh;
                obj.vehicles(veh).setInitialPosition(selectedEdge, distSum);
            end
        end
        
        function setInitDirections(obj)
            for i = 1:length(obj.vehicles)
                edge = obj.vehicles(i).position.edge;
                nodeId = edge.getStartNodeId();
                entranceNodeId = obj.corridors.entranceNodeId;
                if (nodeId == entranceNodeId)
                    obj.vehicles(i).direction = 1;
                else
                    obj.vehicles(i).direction = -1;
                end
            end
        end
        
        function generateDistMatrix(obj)
            obj.distMatrix = zeros(obj.numOfVehicles);
            for i = 1:obj.numOfVehicles - 1
                for j = i + 1:obj.numOfVehicles
                    obj.distMatrix(i, j) = obj.corridors.computeDistance(obj.vehicles(i).position, obj.vehicles(j).position);
                    obj.distMatrix(j, i) = obj.distMatrix(i, j);
                end
            end
        end
        
        function status = isDiscovered(obj, vehicle, FruitBush)
            status = false;
            if(~FruitBush.discovered & vehicle.state == VehState.Exploring & obj.isSameEdge(vehicle.position, FruitBush.position))
                distance = obj.corridors.computeDistance(vehicle.position, FruitBush.position);
                intensity = FruitBush.amount;
                speed = vehicle.vCurrent;
                if(distance < 20)
                    status = true;
                    FruitBush.discovered = true;
                elseif(distance < 100)
                    myRand = randi([1 ceil(distance)*3], 1, 1);
                    if(myRand == 1)
                        status = true;
                        FruitBush.discovered = true;
                    end
                end
            end
        end
        
        function status = isSameEdge(obj, pos1, pos2)
            status = false;
            if(pos1.edge.id == pos2.edge.id)
                status = true;
            end
        end
        
    end
end