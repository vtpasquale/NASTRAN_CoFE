% Abstract superclass for structure
% Anthony Ricciardi
%
classdef (Abstract) structure < element
    
    properties (Abstract)
    end
    
    methods (Abstract)
        element(obj,FEM)
        differential(obj,obj_prime)
    end
    
end

