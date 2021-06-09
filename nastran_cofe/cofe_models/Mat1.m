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
    properties (Dependent = true) 
        E2D % [3,3 double] 2D elasticity matrix
    end
    properties (Access=private)
        E2D_ % [3,3 double] 2D elasticity matrix placeholder
    end
    methods
        function E2D = get.E2D(obj)
            % Dependent on placeholder so only calculated if needed and only calculated once
            if isempty(obj.E2D_)
                obj.E2D_ = obj.E/(1-obj.nu.^2)*[1 obj.nu 0; obj.nu 1 0; 0 0 (1-obj.nu)./2];
            end
            E2D = obj.E2D_;
        end
    end
end
