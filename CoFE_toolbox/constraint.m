% Abstract superclass for constraints
% Anthony Ricciardi
%
classdef (Abstract) constraint < element
    
    properties (Abstract)
    end
    
    methods (Abstract)
        element(obj,FEM)
    end
    
end

