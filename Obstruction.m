classdef (Abstract) Obstruction < handle
    properties (Abstract, SetAccess = immutable)
        id;
        position;
        severity;
    end

    methods (Access = public)
    end
end
