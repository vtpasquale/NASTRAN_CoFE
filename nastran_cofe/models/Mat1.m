% Class for linear isotropic materials.
% Anthony Ricciardi
%
classdef Mat1 < Material
    
    properties
        mid % [uint32] Material identification number. 
        E % [double] Young’s modulus. 
        G % [double] Shear modulus.
        nu % [double] Poisson’s ratio.
        rho % [double] Mass density.
    end
    methods
    end
end
