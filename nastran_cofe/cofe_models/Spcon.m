% Class for single point constraints.
% Anthony Ricciardi
%
classdef Spcon < Spcs
    
    properties
        sid % [uint32] Identification number of single-point constraint set.
        c % [1,: uint32] Component numbers between 1 and 6.
        g % [1,: uint32] Node identification numbers.
        % d % [double] Value of enforced displacement for components c. NOT STORED HERE. Enforced displacement specified using SPCD entry and treated as a load.
    end
end
