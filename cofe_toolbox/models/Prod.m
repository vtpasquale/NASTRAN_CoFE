% Class for tension-compression-torsion element properties.
% Anthony Ricciardi
%
classdef Prod < Property
    
    properties
        pid % Property identification number. (Integer > 0)
        mid % Material identification number. (Integer > 0)
        a % Area of the rod. (Real)
        j % Torsional constant. (Real)
        c % Coefficient to determine torsional stress. (Real)
        nsm % Nonstructural mass per unit length. (Real)
    end
end

