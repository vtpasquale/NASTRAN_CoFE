% Class for tension-compression-torsion element properties.
% Anthony Ricciardi
%
classdef Prod < Property
    
    properties
        pid % [double] Property identification number.
        mid % [double] Material identification number.
        a % [double] Area of the rod.
        j % [double] Torsional constant.
        c % [uint32] Coefficient to determine torsional stress.
        nsm % [uint32] Nonstructural mass per unit length.
    end
    properties (Hidden = true)
        E % [double] Young’s modulus
        G % [double] Shear modulus
        rho % [double] Mass density
    end
    methods
        function obj = setMaterial(obj,model)
            % access and save material data to property object - to save assembly time
            material = model.material.getMaterial(obj.mid,model,'Mat1');
            obj.E = material.E;
            obj.G = material.G;
            obj.rho = material.rho;
        end
    end
end

