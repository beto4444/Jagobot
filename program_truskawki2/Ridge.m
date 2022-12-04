classdef Ridge

    properties(Access=private)
        Pos_xa;
        Pos_ya;
        Pos_xb;
        Pos_yb;
        Width;
        
        graphics;
        graphicstext;
        Totalamount;
    end
    properties(Access=public)
        Fruitarray;

    end
    methods(Access=public)
        function obj = Ridge(Pos_xa, Pos_ya, Pos_xb, Pos_yb, Width)
            obj.Pos_xa=Pos_xa;
            obj.Pos_xb=Pos_xb;
            obj.Pos_ya=Pos_ya;
            obj.Pos_yb=Pos_yb;
            obj.Width=Width;
            

        end
    


end


end