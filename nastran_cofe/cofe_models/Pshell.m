% Class for PSHELL properties.
% Anthony Ricciardi
%
classdef Pshell < Property
    
    properties
        pid  % [uint32] Property identification number
        mid1 % [uint32] Membrane material identification number
        % mid2 % [ int32] Bending material identification number
        % mid3 % [ int32] Transverse shear material identification number
        % mid4 % [ int32] Material identification number for membrane-bending coupling
        t    % [double] Default membrane thickness
        bendRatio  % [double] 12I/T^3 = ratio of the actual bending moment inertia of the shell, I, to the bending moment of inertia of a homogeneous shell, T^3/12. 
        % shearRatio % [double] Ts/T = ratio of the shear thickness, Ts, to the membrane thickness of the shell, T. The typical value is for a homogeneous shell is 0.833333.
        nsm % [double] Nonstructural mass per unit area
        % z1  % [double] Fiber distance for stress calculations
        % z2  % [double] Fiber distance for stress calculations
    end
    properties (Hidden = true)
        rho % [double] Mass density. 
        E2Dm % % [3,3 double] 2D elasticity matrix for membrane response
    end
    methods
        function obj = setMaterial(obj,model)
            % access and save material data to property object - to save assembly time
            material = model.material.getMaterial(obj.mid1,model,'Mat1');
            obj.rho = material.rho;
            obj.E2Dm = material.E2D;
        end
    end
end

