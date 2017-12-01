% Class for scalar mass elements.
% Anthony Ricciardi
%
classdef c_mass1 < elem
    
    properties
        EID % [int] Element identification number.
        PID % [int] Property identification number of a PROD entry. 
        G % [int] Node identification number.
        C % Component number. (0 < Integer < 6; blank or zero if scalar point)
    end
    methods
    end
end
