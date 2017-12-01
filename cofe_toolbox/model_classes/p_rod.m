% Class for tension-compression-torsion element properties.
% Anthony Ricciardi
%
classdef p_rod < prop
    
    properties
        PID % Property identification number. (Integer > 0)
        MID % Material identification number. (Integer > 0)
        A % Area of the rod. (Real)
        J % Torsional constant. (Real)
        NSM % Nonstructural mass per unit length. (Real)
    end
end

