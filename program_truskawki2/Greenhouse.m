classdef Greenhouse
properties(Access = private)
   axes;
   graphicsarray;
   
   humidity;
   shadeness;
   roadgraphnodes;
   roadgraphedges;
   width;
   length;
   ridgesarray;
   vehiclesarray;
    
end    
properties(Access = public)

Graphics;
end
    methods(Access = public)
        function obj = Greenhouse(width, length)
            obj.width=width;
            obj.length=length;
            obj.Graphics = polyshape([0, obj.length, obj.length, 0], [0, 0, obj.width, obj.width]);

    end
    end
end