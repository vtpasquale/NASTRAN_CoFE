% Class for single-point constraints.
% Anthony Ricciardi
%
classdef Spcon < Spcs
    
    properties
        sid % Identification number of single-point constraint set. (Integer > 0)
        c % [1,: int] Component numbers between 1 and 6.
        g % [1,: int] Node identification numbers.
        d % [int] Value of enforced displacement for components C.
    end
    methods
    end
end
