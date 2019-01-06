% Class for linear isotropic materials.
% Anthony Ricciardi
%
classdef Mat1 < Material
    
    properties
        mid % [int] Material identification number. 
        E % [real] Young’s modulus. 
        G % [real] Shear modulus.
        nu % [real] Poisson’s ratio.
        rho % [real] Mass density.
    end
    methods
    end
end
