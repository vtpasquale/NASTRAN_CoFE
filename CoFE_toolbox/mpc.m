% Abstract superclass for multipoint constraints
% Anthony Ricciardi
%
classdef (Abstract) mpc < entry
    
    properties (Abstract)
    end
    
    methods (Abstract)
        element(obj,FEM)
    end
    
end

