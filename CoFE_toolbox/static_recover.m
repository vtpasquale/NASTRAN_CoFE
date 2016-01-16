% Abstract superclass for element with static solution recovery
% Anthony Ricciardi
%
classdef (Abstract) static_recover < element
    
    properties (Abstract)
    end
    
    methods (Abstract)
        recover(obj,gnum2gdof,globalDef,obj_prime,globalDef_prime)
        write_recover(obj_array,fid)
    end
    
end

