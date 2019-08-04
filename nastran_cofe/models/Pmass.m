% Class for scalar mass element properties.
% Anthony Ricciardi
%
classdef Pmass < Property
    
    properties
        pid % Property identification number. (Integer > 0)
        m % Value of scalar mass. (Real)
    end
    methods
        function obj = setMaterial(obj,model)
            % Access and save material data to property object - to save assembly time
            % Void for this case. Function required to conform to property
            % superclass.
        end
    end
end

