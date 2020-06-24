% Class for beam element properties.
% Used for bar element properties as well. 
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
        function [C1,C2,D1,D2,E1,E2,F1,F2]=getStressLocations(obj)
            % Helper function to deal locations to seperate variables
            [C1,C2,D1,D2,E1,E2,F1,F2]=deal(obj.c1ThruF2(1),...
                obj.c1ThruF2(2),obj.c1ThruF2(3),obj.c1ThruF2(4),...
                obj.c1ThruF2(5),obj.c1ThruF2(6),obj.c1ThruF2(7),...
                obj.c1ThruF2(8));
        end
    end
end

