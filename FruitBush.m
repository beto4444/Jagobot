classdef FruitBush < handle
    properties (Constant)
        WORKTIME_MUL = 5000;
    end
    
    properties (SetAccess = immutable)
        id;
        position;
        appearanceTime;
        %severity
        amount;
        %currentseverity
        currentamount;
        initWorkTimeToRemove;
        maxVehicles;
        side;
        
    end

    properties (SetAccess = protected)
        workTimeToRemove;
        PickingVehicle;
    end
    
    properties (SetAccess = private)
        statMitigationStepsSum;
        statOptimalTeamStepsSum;
    end
    
    properties (Access = public)
        discovered;
        timeOfDiscovery;
    end
    
    methods (Access = public)
        function obj = FruitBush(inputData, corridors)
            obj.id = inputData(1);
            obj.position = Position(corridors.getEdge(inputData(2)), inputData(3));
            obj.appearanceTime = inputData(4);
            obj.amount = inputData(5);
            obj.side=inputData(7);
            obj.currentamount=obj.amount;
            obj.workTimeToRemove = round(obj.amount*10);
            obj.initWorkTimeToRemove = obj.workTimeToRemove;
            obj.discovered = false;
            obj.PickingVehicle = [];
            obj.maxVehicles = inputData(6);
            obj.timeOfDiscovery = -1;
            obj.statMitigationStepsSum = 0;
            obj.statOptimalTeamStepsSum = 0;
        end
        
        function status = isReloadd(obj)
            status = false;
            if(obj.workTimeToRemove <= 0)
                status = true;
            end
        end
        
        function status = Reload(obj, vehicle)
            status = false;
            if(~ismember(vehicle, obj.PickingVehicle) && length(obj.PickingVehicle) < obj.maxVehicles && ~obj.isReloadd())
                obj.PickingVehicle = [obj.PickingVehicle, vehicle];
            end
            if(ismember(vehicle, obj.PickingVehicle))
                status = true;
            end
        end
        
        function updateWorkTime(obj, boost)
            if(~obj.isReloadd() && ~isempty(obj.PickingVehicle))
                mitSpeed = obj.getMitigationSpeed(boost);
                obj.workTimeToRemove = obj.workTimeToRemove - mitSpeed;
                if(obj.workTimeToRemove < 0)
                    obj.workTimeToRemove = 0;
                end
                obj.updateStats();
            else
                obj.PickingVehicle = [];
            end
        end
        
        function stopMitigation(obj)
            obj.PickingVehicle = [];
        end
        
        
        function damage = getDamage(obj)
           % damage = obj.severity/(4*obj.getMitigationSpeed(false));
           damage = 1;
        end
        
        function num = getNumOfMitigatingVehicles(obj)
            num = length(obj.PickingVehicle);
        end
        
        function result = getTimeToDiscover(obj)
            result = -1;
            if(obj.timeOfDiscovery > 0)
                result = obj.timeOfDiscovery - obj.appearanceTime;
            end
        end
        
        function disp(obj)
            disp(['---- FruitBush ', int2str(obj.id), ' ----']);
            obj.position.disp();
            disp(['Severity: ', num2str(obj.amount)]);
            disp(['WorkTime: ', num2str(obj.initWorkTimeToRemove - obj.workTimeToRemove), '/', num2str(obj.initWorkTimeToRemove)]);
            disp(['Discovered: ', int2str(obj.discovered)]);
            disp(['Max vehs: ', int2str(obj.maxVehicles)]);
        end
    end
    
    methods (Access = private)
        function speed = getMitigationSpeed(obj, boost)
            speed = length(obj.PickingVehicle);
            if(speed > 0)
                speed = 1;
            end
            if(boost)
                speed = speed*(randn*0.01+0.12 + 1);
%                 zamieniono normrnd(0.12, 0.01) na randn*0.01+0.12
%                 powód: randn jest w bazowym matlabie, normrnd jest w
%                 osobnym toolboxie(machine learning toolbox)
            end
        end
        
        function updateStats(obj)
            obj.statMitigationStepsSum = obj.statMitigationStepsSum + 1;
            if(length(obj.PickingVehicle) == obj.maxVehicles)
                obj.statOptimalTeamStepsSum = obj.statOptimalTeamStepsSum + 1;
            end
        end
    end
end