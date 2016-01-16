% Abstract superclass for elements
% Anthony Ricciardi
%
classdef (Abstract) element < entry
    
    properties (Abstract)
        % gdof % [ndof,1] vector of global degrees of freedom indices
    end
    
    methods (Abstract)
        
        % Plot undeformed and deformed element
        plot(obj,allDef,varargin)
        
    end
    
end

