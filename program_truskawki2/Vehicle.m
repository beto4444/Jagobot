classdef Vehicle

    properties(SetAccess=immutable)
        Width;
        Length;
        Height;
        Weight;
        Max_speed;
        Max_acceleration;
        Min_speed;%if robot can ride reverse minus value,
        %otherwise =0
        Capacity;%grams
        %Max_turn;
        Max_Battery;%MWh??
        %Radar_range;
        Com_range;
        Start_x;
        Start_y;
        Arm_range;

    end

    properties(Access=private)
        Direction;%angles: 0 - up, 90 - right, 180 - down, 270 - left
        Greenhouse;
       
        Current_speed;
        Current_acceleration;
        Current_turn;
        Current_load;%array of picked strawberries
        Total_load;%Total mass of picked strawberries
        Damage;%in future - array of specified components, 
        % eg. wheels, camera etc
        Current_battery;
        State;%???
        polygon_color;

    end

    properties(GetAccess=public)
    current_x;
    current_y;
     Graphics;
     graphics_xcoords;
     graphics_ycoords;
    end

    methods(Access=public)
        function obj = Vehicle(Start_x, Start_y, Greenhouse)
            obj.Width=5;
            obj.Length=3;
            obj.Max_speed=30;
            obj.Capacity=2000;
            obj.Arm_range=2;
            obj.Start_x=Start_x;
            obj.Start_y=Start_y;
            obj.current_x=Start_x;
            obj.current_y=Start_y;
            obj.Direction=0;
            obj.Greenhouse=Greenhouse;
            obj.Current_speed=0;
            obj.Current_turn=0;
            obj.Current_load=0;
            obj.Damage=0;
            obj.polygon_color='g';
            obj.Current_battery=500;

            
            x0=obj.Start_x;
            y0=obj.Start_y;
            l=obj.Length;
            w=obj.Width;
            obj.graphics_xcoords=[x0-l/2, x0-l/4, x0+l/4, x0+l/2, x0+l/4, x0-l/4];
            obj.graphics_ycoords=[y0, y0+w/2, y0+w/2, y0, y0-w/2, y0-w/2];
            obj.Graphics=polyshape(obj.graphics_xcoords, obj.graphics_ycoords);
            

        end





        function obj = SetTurn(obj, new)
            obj.Current_turn=new;
        end

        function obj = SetSpeed(obj, new)
            obj.Current_speed=new;
        end

        function obj = step(obj)
            obj.Current_battery=obj.Current_battery-1;
%             deltax=obj.Current_speed*cos(obj.Current_turn);
%             deltay=obj.Current_speed*sin(obj.Current_turn);

            deltax=10;
            deltay=10;
            obj.current_x=obj.current_x+deltax;
            obj.current_y=obj.current_y+deltay;
            obj.graphics_xcoords=obj.graphics_xcoords+deltax;
            obj.graphics_ycoords=obj.graphics_ycoords+deltay;
        end

        function [obj, time] = pickstrawberry(obj, ridge, numofbush, side)%side = 1 - left, side = 2 - right
            if(ridge.fruitarray(side, numofbush)~=0)
            picked = ridge.fruitarray(side,numofbush);
            obj.Current_load=obj.Current_load+picked;
            ridge.fruitarray(side, numofbush)=0;
            time=floor(picked/2+1);
            else
                time=0;
            end

    end
    end
end