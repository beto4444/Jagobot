classdef Strawberry < handle
    %STRAWBERRY Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess=public, SetAccess=immutable)
        Plantday;%Day when fruit was planted(default - 1)
        Variety;
        Weight;
    end    
    properties(GetAccess=public, SetAccess=private)
        State;%Described in corresponding .docx file
        Age;
        MatureTime;
        RottenTime;
        StateChangeTime;
            %array of transistion time for corresponding state,
            %e.g. StateChangeTime(1) = 0; time when strawberry get state 0
            %StateChangeTime(2) = 2; time when strawberry get state 1(day 2) etc..
        
    end


    
    methods(Access=public)
        function obj = Strawberry(Plantday, State, Variety, Weight)
            obj.State=State;
            obj.Plantday=Plantday;
            obj.Variety=Variety;
            obj.Age=0;
            obj.Weight=Weight;
            obj.MatureTime=-1;
            obj.RottenTime=-1;
        end
        
        function updateAge(obj, currentday)
            obj.Age=currentday-obj.Plantday;
        end

        function AddAge(obj)
            obj.Age=obj.Age+1;
        end
        
        function changeState(obj, newState)
            obj.State=newState;
            if(newState==1)
                obj.MatureTime=obj.Age;
            elseif(newState==-1)
                obj.RottenTime=obj.Age;
            end
        end
    end
end

