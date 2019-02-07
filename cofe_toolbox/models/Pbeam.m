% Class for beam element properties.
% Anthony Ricciardi
%
classdef Pbeam < Property
    
    properties
        pid % [uint32] Property identification number
        mid % [uint32] Material identification number
        a % [double] Area of the cross section
        i1 % [double] Area moments of inertia
        i2 % [double] Area moments of inertia
        j % [double] Torsional constant
        nsm % [double] Nonstructural mass per unit length
        c1ThruF2 % [1,8 double] Stress recovery locations
        k1 % [double] Area factor for shear
        k2 % [double] Area factor for shear
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

