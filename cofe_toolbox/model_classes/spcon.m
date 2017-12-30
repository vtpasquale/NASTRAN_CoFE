% Class for single-point constraints.
% Anthony Ricciardi
%
classdef spcon < spcs
    
    properties
        SID % Identification number of single-point constraint set. (Integer > 0)
        C % [1,: int] Component numbers between 1 and 6.
        G % [1,: int] Node identification numbers.
        D % [int] Value of enforced displacement for components C.
    end
    methods
    end
end
