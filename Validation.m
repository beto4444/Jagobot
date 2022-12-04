classdef Validation 
    properties (Constant)
        TGT_NEAR = 1.00;
    end
    
    methods (Static)
        function status = test()
            status = true;
        end
        
        function status = isSameEdge(pos1, pos2)
            status = false;
            if(pos1.edge.id == pos2.edge.id)
                status = true;
            end
        end
    end
    

end