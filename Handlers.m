classdef (Abstract) Handlers < handle 
    
    properties (Abstract, Access = protected)
        step;
    end
    
    methods (Abstract, Access = public)
        takeStep(obj);
        loadFromFile(obj, fileName, tabName, corridors);
    end
    
    methods (Access = protected)
        function [fromList, toList, diffList] = updateLists(obj, fromList, toList, diffList, checkFun)
            oldActivated = toList;
            [fromList, toList] = obj.swapListIfChecked(fromList, toList, checkFun);
            newActivated = toList;
            diffList = obj.getNewElements(oldActivated, newActivated);
        end
        
        function [fromList, toList] = swapListIfChecked(obj, fromList, toList, checkFun)
            index = 1;
            while index <= length(fromList)
                if(checkFun(fromList(index)))
                    toList = [toList, fromList(index)];
                    fromList(index) = [];
                else
                    index = index + 1;
                end
            end
        end
        
        function [list] = getNewElements(obj, old, new)
            list = [];
            for i = 1:length(new)
                if(~ismember(new(i), old))
                    list = [list new(i)];
                end
            end
        end
        
        function status = isAppeared(obj, myObject)
            status = false;
            if(myObject.appearanceTime <= obj.step)
                status = true;
            end
        end
    end
end