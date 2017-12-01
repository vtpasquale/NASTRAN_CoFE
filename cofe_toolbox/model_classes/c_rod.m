% Class for tension-compression-torsion elements.
% Anthony Ricciardi
%
classdef c_rod < elem
    
    properties
        EID % [int] Element identification number.
        PID % [int] Property identification number of a PROD entry. 
        G % [1,2 int] Grid point identification numbers of connection points.
    end
    methods
    end
end
