% budowa robota:
% ramie, platforma, chwytak, akumulator
% lidar

classdef Vehicle < handle
    properties (Constant)
        VMAX = 1.0;
        ACCMAX = 1.0;
        BROKEN_THR = 1000;
        CAPACITY = 10; % zmienione z broken_thr=100;
        HARVESTINGSPEED=0.25;

    end
    
    properties (SetAccess = immutable)
        id;
        corridors;
        group;
    end
    
    properties (Access = private)
        relatedObstacle;
        pathSeeker;
        nextPosition;
        supervisor;
    end
    
    properties (SetAccess = private)
        state;
        position;
        vCurrent;
        vCurrentMax;
        accCurrent;
        accCurrentMax;
        exploreTgtPos;
        exploreTgtPosReached
        discoveredFruitBush;
        FruitBushToAssist;
        FruitBushReached;
        obstacles;
        f;
        damage;
        damageOverall;
        energyConsumption;
        timeToWait;
        canReload;
        recoverCounter;
        statNumOfRepairs;
        statNumOfKm;
        stats;
        waitedAfterDiscovered;
        CapacityMax;
        CapacityCurrent;

    end
    
    properties (Access = public)
        direction;
    end
    
    methods (Access = public)
        function obj = Vehicle(id, corridors, group, j)
            obj.CapacityMax=obj.CAPACITY;
            obj.CapacityCurrent=0.0;
            obj.id = id;
            obj.vCurrent = 0.0;
            obj.vCurrentMax = obj.VMAX;
            obj.accCurrent = 0.0;
            obj.accCurrentMax = obj.ACCMAX;
            obj.position = Position((j-1)*200, 0);
            obj.relatedObstacle = [];
            obj.state = VehState.Exploring;
            obj.corridors = corridors;
            obj.obstacles = [];
            obj.discoveredFruitBush = [];
            obj.FruitBushToAssist = [];
            obj.FruitBushReached = false;
            obj.pathSeeker = PathSeeker(corridors);
            obj.nextPosition = [];
            obj.exploreTgtPos = [];
            obj.exploreTgtPosReached = true;
            obj.group = group;
            obj.supervisor = [];
            obj.f = 0;
            obj.energyConsumption = 0;
            obj.damage = 0;
            obj.damageOverall = 0;
            obj.timeToWait = 0;
            obj.canReload = false;
            obj.recoverCounter = 0;
            obj.statNumOfRepairs = 0;
            obj.statNumOfKm = 0;
            obj.stats.state = [0, uint32(obj.state)];
            obj.waitedAfterDiscovered = false;
        end
        
        function str = getPathToTarget(obj)
            str = '';
            for i = 1:length(obj.pathSeeker.edgePathToTarget)
                cEdge = obj.pathSeeker.edgePathToTarget(i);
                str = [str num2str(cEdge.id)];
            end
        end
        
        function setInitialPosition(obj, edge, dist)
            obj.position.edge = edge;
            obj.position.distance = dist;
        end
        
        function addDiscoveredFruitBush(obj, FruitBush)
            if(isempty(obj.discoveredFruitBush))
                obj.discoveredFruitBush = FruitBush;
            end
            obj.state = VehState.DiscoveryConfirmed;
            obj.waitedAfterDiscovered = false;
            obj.pathSeeker.clearTarget();
            obj.FruitBushReached = false;
            obj.canReload = false;
        end
        
        function handleReloaddFruitBush(obj, FruitBushes)
            % disp(['Vehicle: ', num2str(obj.id)]);
            % for i = 1:length(FruitBushes)
                % disp(['    FruitBush: ', num2str(FruitBushes(i).id)]);
            % end
            if(ismember(obj.discoveredFruitBush, FruitBushes))
                obj.state = VehState.Exploring;
                % disp(['        DiscFruitBush: ', num2str(obj.discoveredFruitBush.id)]);
                obj.discoveredFruitBush = [];
            elseif(ismember(obj.FruitBushToAssist, FruitBushes))
                obj.state = VehState.Exploring;
                % disp(['        AssistFruitBush: ', num2str(obj.FruitBushToAssist.id)]);
                obj.FruitBushToAssist = [];
            end
        end
        
        function assistReq(obj, FruitBush, timeToWait)
            if(obj.state == VehState.Exploring)
                obj.FruitBushToAssist = FruitBush;
                obj.state = VehState.Assisting;
                obj.pathSeeker.clearTarget();
                obj.FruitBushReached = false;
                obj.canReload = false;
                obj.timeToWait = timeToWait;
            end
        end
        
        function ReloadReq(obj)
            obj.canReload = true;
        end
        
        function stopReq(obj)
            obj.canReload = false;
        end
        
        function addKnownObstacles(obj, obs)
            for i = 1:length(obs)
                obj.obstacles = [obj.obstacles obs(i)];
            end
        end
        
        function setExploreTgtPos(obj, pos)
            if(obj.state == VehState.Exploring)
                obj.pathSeeker.clearTarget();
            end
            obj.exploreTgtPos = pos;
            obj.exploreTgtPosReached = false;
        end
        
        function executeAction(obj, step)
            obj.updateAcceleration();
            obj.updateVelocity();
            if(obj.state == VehState.Exploring && obj.timeToWait > 0)
                obj.timeToWait = obj.timeToWait - 1;
                cmd = VehIntCmd.Stop;
            else
                cmd = obj.getCommand();
            end
            switch cmd
                case VehIntCmd.Stop
                    obj.stop();
                case VehIntCmd.Move
                    obj.move();
                case VehIntCmd.SlowMove
                    dist = obj.getDistForSlowMove();
                    obj.slowMove(dist);
                case VehIntCmd.MoveBack
                    obj.moveBack();
                case VehIntCmd.MoveToNewEdge
                    obj.moveToNewEdge();
                case VehIntCmd.Reload
                    obj.Reload();
                otherwise
                    obj.stop();
            end
            obj.updateDmgFromObstacleIfNotRepairing();
            obj.updateF();
            obj.saveStats(step);
        end
        
        function id = getRelatedObstacleId(obj)
            id = '';
            if(~isempty(obj.relatedObstacle))
                id = int2str(obj.relatedObstacle.id);
            end
        end
        
        function str = getTargetStr(obj)
            str = '';
            if(~isempty(obj.pathSeeker.targetPos))
                str = ['(', int2str(obj.pathSeeker.targetPos.edge.id), ',', num2str(obj.pathSeeker.targetPos.distance, '%.2f'), ')'];
            end
        end
    end
    
    methods (Access = private)
        function updateAcceleration(obj)
            obj.accCurrent = obj.accCurrentMax;
        end
        
        function updateVelocity(obj)
            obj.updateVelocityCurrrentMax();
            obj.vCurrent = obj.vCurrent + obj.accCurrent/1.0;
            if obj.vCurrent > obj.vCurrentMax
                obj.vCurrent = obj.vCurrentMax;
            end
        end
        
        function cmd = getCommand(obj)
            obj.sendVehicleDataToPathSeeker();
            switch(obj.state)
                case VehState.Exploring
                    if(obj.needsRepair())
                        obj.state = VehState.Repairing;
                        cmd = VehIntCmd.Stop;
                    else
                        obj.setPathSeekerTgtIfEmpty(obj.exploreTgtPos);
                        cmd = obj.pathSeeker.getMoveCommand();
                        cmd = obj.handleExploreTgtPosReached(cmd);
                    end
                case VehState.DiscoveryConfirmed
                    if(~obj.waitedAfterDiscovered)
                        obj.waitedAfterDiscovered = true;
                    else
                        obj.tryToBecomeCoordinator();
                    end
                    cmd = VehIntCmd.Stop;
                case VehState.Coordination
                    if(~obj.supervisor.isBestTeam)
                        if(obj.supervisor.extendTeam())
                            obj.supervisor.requestStop();
                        end
                    end
                    if(obj.supervisor.isTeamReady() && ~obj.supervisor.mitigationRequested)
                        obj.supervisor.requestReload();
                    end
                    cmd = obj.reachAndReload(obj.discoveredFruitBush);
                case VehState.Assisting
                    cmd = obj.reachAndReload(obj.FruitBushToAssist);
                case VehState.Waiting
                    obj.tryToBecomeCoordinator();
                    cmd = VehIntCmd.Stop;
                case VehState.Repairing
                    obj.recover();
                    cmd = VehIntCmd.Stop;
                otherwise
                    cmd = VehIntCmd.Stop;
            end
            obj.checkExploreTgtPosReached();
            obj.predictNextPosition(cmd);
            if(~obj.IsNextPositionValid())
                cmd = VehIntCmd.MoveToNewEdge;
            end
        end
        
        function sendVehicleDataToPathSeeker(obj)
            obj.pathSeeker.vehPosition = obj.position;
            obj.pathSeeker.vehDirection = obj.direction;
        end
        
        function setPathSeekerTgtIfEmpty(obj, pos)
            if(obj.pathSeeker.isTargetEmpty)
                obj.pathSeeker.setTarget(pos);
            end
        end
        
        function cmd = handleExploreTgtPosReached(obj, cmd)
            if(cmd == VehIntCmd.TargetReached)
                obj.exploreTgtPosReached = true;
                cmd = VehIntCmd.Stop;
                obj.pathSeeker.clearTarget();
            end
        end
        
        function tryToBecomeCoordinator(obj)
            if(obj.group.supervisionRightsRequest(obj))
                obj.state = VehState.Coordination;
                obj.supervisor = obj.group.getSupervisionRights(obj);
                obj.supervisor.extendTeam();
            else
                obj.state = VehState.Waiting;
            end
        end
        
        function cmd = reachAndReload(obj, FruitBush)
            if(~obj.FruitBushReached)
                cmd = obj.gotoFruitBush(FruitBush);
            elseif(obj.canReload)
                cmd = obj.tryToReload(FruitBush);
            else
                cmd = VehIntCmd.Stop;
            end
        end
        
        function cmd = gotoFruitBush(obj, FruitBush)
            obj.setPathSeekerTgtIfEmpty(FruitBush.position);
            cmd = obj.pathSeeker.getMoveCommand();
            cmd = obj.handleFruitBushTgtPosReached(cmd);
        end

        function cmd = handleFruitBushTgtPosReached(obj, cmd)
            if(cmd == VehIntCmd.TargetReached)
                cmd = VehIntCmd.Stop;
                obj.FruitBushReached = true;
                obj.pathSeeker.clearTarget();
            end
        end
        
        function cmd = tryToReload(obj, FruitBush)
            if(FruitBush.Reload(obj))
                cmd = VehIntCmd.Reload;
            else
                cmd = VehIntCmd.Stop;
            end
        end
        
        function stop(obj)
            obj.accCurrent = 0;
            obj.vCurrent = 0;
            if(obj.state == VehState.Repairing)
                obj.addToEnergyConsumption(2);
            else
                obj.addToEnergyConsumption(0.1);
            end
        end
        
        function Reload(obj)
            obj.stop();
            if(obj.state == VehState.Coordination)
                cFruitBush = obj.discoveredFruitBush;
            elseif(obj.state == VehState.Assisting)
                cFruitBush = obj.FruitBushToAssist;
            end
            obj.addToDamage(cFruitBush.getDamage());
            obj.addToCapacity();
            if(obj.group.algorithm == Algorithm.Anticipatory)
                M = cFruitBush.getNumOfMitigatingVehicles();
                energyUsed = 1.1*(1-0.05*(M-1));
            else
                energyUsed = 1.1;
            end
            obj.addToEnergyConsumption(energyUsed);
        end
    
        function move(obj)
            obj.updatePosition();
            obj.relatedObstacle = obj.handleObstaclesEffects();
            obj.addToEnergyConsumption(1);
            obj.statNumOfKm = obj.statNumOfKm + obj.vCurrent*0.001;
        end
        
        function slowMove(obj, dist)
            if(dist <= obj.VMAX)
                obj.position.distance = obj.position.distance + dist*obj.direction;
                obj.accCurrent = obj.vCurrent - dist;
                obj.vCurrent = dist;
                obj.addToEnergyConsumption(dist);
                obj.statNumOfKm = obj.statNumOfKm + dist*0.001;
            else
                obj.move();
            end
        end
        
        function moveBack(obj)
            obj.direction = -obj.direction;
            obj.move();
        end
        
        function moveToNewEdge(obj)
            [obj.position, obj.direction] = obj.handleInvalidVehPosition(obj.checkPosition(obj.nextPosition), obj.nextPosition);
        end
        
        function updateVelocityCurrrentMax(obj)
            obj.vCurrentMax = obj.VMAX - obj.damage/1000;
            if(~isempty(obj.relatedObstacle))
                obj.vCurrentMax = obj.vCurrentMax - obj.relatedObstacle.velocityDerate;
            end
        end
        
        function updatePosition(obj)
            obj.position.distance = obj.position.distance + (obj.vCurrent/1.0)*obj.direction;
        end

        function setNextEdge(obj, currentNode)
            dist = newEdge.getDistanceForNode(currentNode.id);
            obj.setPosition(newEdge, dist);
        end
        
        function predictNextPosition(obj, cmd)
            obj.nextPosition = [];
            direction = obj.direction;
            if(cmd == VehIntCmd.Move || cmd == VehIntCmd.MoveBack)
                if(cmd == VehIntCmd.MoveBack)
                    direction = -direction;
                end
                predictedDistance = obj.position.distance + obj.vCurrent*direction;
                obj.nextPosition = Position(obj.position.edge, predictedDistance);
            end
        end
        
        function checkExploreTgtPosReached(obj)
            if(Validation.isSameEdge(obj.position, obj.exploreTgtPos))
                dist = abs(obj.position.distance - obj.exploreTgtPos.distance);
                if(dist <= Validation.TGT_NEAR)
                    obj.exploreTgtPosReached = true;
                end
            end
        end
        
        function status = needsRepair(obj)
            status = false;
            if(obj.damage > obj.BROKEN_THR)
                status = true;
            end
        end
        
        function status = IsNextPositionValid(obj)
            status = true;
            if(~isempty(obj.nextPosition) & obj.checkPosition(obj.nextPosition) ~= VehOnEdgePosition.Valid)
                status = false;
            end
        end
        
        function status = checkPosition(obj, position)
            if position.distance > position.edge.distance
                status = VehOnEdgePosition.EndNodeExceeded;
            elseif position.distance < 0
                status = VehOnEdgePosition.StartNodeExceeded;
            else
                status = VehOnEdgePosition.Valid;
            end
        end

        function [newPosition, newDirection] = handleInvalidVehPosition(obj, status, position)
            node = [];
            distExceeded = [];
            if (status == VehOnEdgePosition.StartNodeExceeded) 
                node = position.edge.startNode;
                distExceeded = -position.distance;
            elseif (status == VehOnEdgePosition.EndNodeExceeded)
                node = position.edge.endNode;
                distExceeded = position.distance - position.edge.distance;
            end
            newEdge = obj.getNextEdge(node);
            newDist = obj.getNextDist(node, newEdge, distExceeded);
            newPosition = Position(newEdge, newDist);
            newDirection = obj.getNextDirection(node, newEdge);
        end
        
        function edge = getNextEdge(obj, node)
            %edge = obj.getRandAdjEdge(node);
            edge = obj.pathSeeker.getNextEdge();
        end
        
        function edge = getRandAdjEdge(obj, node)
            numOfEdges = node.getNumOfAdjEdges();
            newEdgeId = randi(numOfEdges);
            edge = node.getAdjEdge(newEdgeId);
        end
        
        function dist = getNextDist(obj, node, newEdge, distExceeded)
            dist = newEdge.getDistanceFromNode(node.id, distExceeded);
        end
        
        function direction = getNextDirection(obj, node, newEdge)
           if (node.id == newEdge.getStartNodeId())
               direction = 1;
           else
               direction = -1;
           end
        end
        
        function dist = getDistForSlowMove(obj)
            targetDist = obj.pathSeeker.targetPos.distance;
            vehDist = obj.pathSeeker.vehPosition.distance;
            dist = abs(targetDist - vehDist);
        end
        
        function obstacle = handleObstaclesEffects(obj)
            obstacle = [];
            for i = 1:length(obj.obstacles)
                impacted = obj.obstacles(i).impacts(obj.position);
                if impacted
                    obstacle = obj.obstacles(i);
                    break;
                end
            end
        end
        
        function addToEnergyConsumption(obj, value)
            obj.energyConsumption = obj.energyConsumption + value*0.001;
        end
        
        function addToDamage(obj, value)
%             obj.damage = obj.damage + value;
        rest = 100 - obj.damage;
       % obj.damage = obj.damage + (value/100)*rest;
       obj.damage=obj.damage + value;
        end

        function addToCapacity(obj, numofvehicles)
            obj.CapacityCurrent=obj.CapacityCurrent+obj.HARVESTINGSPEED;
            
        end
        function updateF(obj)
            obj.f = obj.energyConsumption/100 + obj.damage;
        end
        
        function updateDmgFromObstacleIfNotRepairing(obj)
            if(~isempty(obj.relatedObstacle) && ~(obj.state == VehState.Repairing))
                dmg = obj.relatedObstacle.getDamage();
                obj.addToDamage(dmg);
            end
        end
        
        function recover(obj)
            if(obj.recoverCounter < 300)
                obj.recoverCounter = obj.recoverCounter + 1;
            else
                obj.state = VehState.Exploring;
                obj.recoverCounter = 0;
                obj.damageOverall = obj.damageOverall + obj.damage;
                obj.damage = 0;
                obj.statNumOfRepairs = obj.statNumOfRepairs + 1;
            end
        end
        
        function saveStats(obj, step)
            obj.saveStateStat(step);
        end
        
        function saveStateStat(obj, step)
            cState = uint32(obj.state);
            lState = obj.stats.state(end, 2);
            if(cState ~= lState)
                obj.stats.state = [obj.stats.state; step, cState];
            end
        end
    end
    
end

