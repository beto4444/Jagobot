classdef Ridge
    properties(SetAccess = immutable)
        startx;
        starty;
        endx;
        endy;
        width;
        length;
        numofsymbols;
        totalamount;
        startamount;
    end
    properties(Access = private)
       fruitarray; %2-n array; first row - num of strawberries per 0.25 m on left;
                   %           secund row - num of fruits per 0.25 m on right;
                   %           n = length[m]/0.25m
    end

    methods(Access = public)


        function obj = Ridge(startx, starty, endx, endy, width, length, numofsymbols, fruitarray)
            if fruitarray==0
            obj.fruitarray=ones(length, 2);
            else
                obj.fruitarray=fruitarray;
            end
            obj.startx=startx;
            obj.starty=starty;
            obj.endx=endx;
            obj.endy=endy;
            obj.width=width;
            obj.length=length;
            obj.numofsymbols=numofsymbols;
            obj.startamount=sum(fruitarray);
            obj.totalamount=obj.startamount;
        end


        function editfruitvalue(obj, new, coord, side)
            obj.fruitarray(coord, side)=new;
        end
        
        function isempty = takefruit(obj, coord, side)
            if obj.fruitarray(coord, side)>0
                isempty=0;
                obj.fruitarray(coord, side)=obj.fruitarray(coord,side)-1;
            else
                isempty=1;
            end

        end
        function loadfruitarray(obj, newfruitarray)
            obj.fruitarray=newfruitarray;
        end

    end
end