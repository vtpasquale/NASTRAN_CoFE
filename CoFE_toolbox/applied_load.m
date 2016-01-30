% Abstract superclass for elements
% Anthony Ricciardi
%
classdef (Abstract) applied_load < entry
    
    properties (Abstract)
        % gdof % [ndof,1] vector of global degrees of freedom indices
        SID
    end
    
    methods (Abstract)
        
        % determine load components and values
        apply(obj,FEM,lc)
        
    end
    
end

