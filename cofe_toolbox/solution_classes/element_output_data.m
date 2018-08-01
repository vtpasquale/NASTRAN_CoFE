% Class for output data at elements
% Anthony Ricciardi
%
classdef element_output_data
    
    properties
        stress % [6,nm,nrp] Array of stress vectors using Voigt notation [[s11 s22 s33 s23 s13 s12]',nm,nrp], where nm is the number of response modes and nrp is the number of element recovery points.
        strain % [6,nm,nrp] Array of strain vectors using Voigt notation [[e11 e22 e33 e23 e13 e12]',nm,nrp], where nm is the number of response modes and nrp is the number of element recovery points.
        ese % [nm,1] Element strain energy for all response modes
        eke % [nm,1] Element kinetic energy for all response modes
    end
    
    methods
        function obj = recover_stress(obj,MODEL,u_g)
        end
    end
end
