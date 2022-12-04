classdef FruitBushesAxesHost < handle 
    properties (Access = private)
        emptyAxes;
        FruitBushAxes;
        FruitBushPrinter;
        FruitBushes;
        vehsPerFruitBush;
    end
    
    properties (SetAccess = immutable)
        FruitBushesFig;
    end
    
    
    methods (Access = public)
        function obj = FruitBushesAxesHost(fig)
            obj.emptyAxes = zeros(1,8) + 1;
            obj.FruitBushAxes = cell(1,8);
            obj.FruitBushPrinter = cell(1,8);
            obj.FruitBushes = cell(1,8);
            obj.FruitBushesFig = fig;
            obj.vehsPerFruitBush = zeros(1,8);
        end
        
        function createFruitBushAxes(obj, FruitBush)
            id = obj.getNextFreeAxes();
            obj.FruitBushes{id} = FruitBush;
            row = mod(id, 4);
            col = floor(id/4) + 1;
            obj.FruitBushAxes{id} = uiaxes(obj.FruitBushesFig);
            obj.FruitBushAxes{id}.Position = [(col-1)*300 600-row*150 300 150];
            obj.FruitBushAxes{id}.Box = 'on';
            obj.FruitBushAxes{id}.Visible = 'off';
            obj.FruitBushPrinter{id} = FruitBushPrinter(obj.FruitBushAxes{id});
        end
        
        function update(obj)
            cVehsPerFruitBush = obj.getVehsPerFruitBushAndStop();
            diff = cVehsPerFruitBush - obj.vehsPerFruitBush;
            ids = find(diff > 0);
            obj.updateFruitBushesPrinters(ids);
            obj.vehsPerFruitBush = cVehsPerFruitBush;
        end
    end
        
        
    methods (Access = private)
        function result = getNextFreeAxes(obj)
            result = find(obj.emptyAxes);
            result = result(1);
            obj.emptyAxes(result) = 0;
        end
        
        function release(obj, id)
            obj.emptyAxes(id) = 1;
            obj.FruitBushes{id} = [];
            obj.FruitBushPrinter{id} = [];
            cla(obj.FruitBushAxes{id});
            obj.FruitBushAxes{id} = [];
        end
        
        function vehs = getVehsPerFruitBushAndStop(obj)
            vehs = zeros(1,8);
            activeIds = find(not(obj.emptyAxes));
            for id = activeIds
                vehs(id) = length(obj.FruitBushes{id}.mitigatingVehicles);
                if(obj.FruitBushes{id}.isReloadd)
                    obj.release(id);
                end
            end
        end
        
        function updateFruitBushesPrinters(obj, ids)
            while(~isempty(ids))
                obj.FruitBushPrinter{ids(1)}.addVehicle();
                ids(1) = [];
            end
        end
    end
end