% Class for PSHELL properties.
% Anthony Ricciardi
%
classdef Pshell < Property
    
    properties
        pid  % [uint32] Property identification number
        mid1 % [uint32] Membrane material identification number
        mid2 % [ int32] Bending material identification number
        mid3 % [ int32] Transverse shear material identification number
        mid4 % [ int32] Material identification number for membrane-bending coupling
        t    % [double] Default membrane thickness
        bendRatio  % [double] 12I/T^3 = ratio of the actual bending moment inertia of the shell, I, to the bending moment of inertia of a homogeneous shell, T^3/12. 
        shearRatio % [double] Ts/T = ratio of the shear thickness, Ts, to the membrane thickness of the shell, T. The typical value is for a homogeneous shell is 0.833333.
        nsm % [double] Nonstructural mass per unit area
        % z1  % [double] Fiber distance for stress calculations
        % z2  % [double] Fiber distance for stress calculations
    end
    properties (Hidden = true)
        isMembrane % [logical] true if property includes membrane terms
        rho % [double] Mass density. Structural mass is calculated from the density using the membrane material properties.
        E2dMembrane % % [3,3 double] Membrane 2D elasticity matrix
        
        isPlate % [logical] true if property includes plate terms
        E2dBend % [3,3 double] Bending 2D elasticity matrix
        E2dShear % [3,3 double] Shear 2D elasticity matrix        
    end
    methods
        function obj = setMaterial(obj,model)
            % access and save material data to property object - to save assembly time
            if ~isempty(obj.mid4); error('Membrane-bending coupling not supported. MID4 should be blank.'); end
            if all([isempty(obj.mid1),isempty(obj.mid2)])
                error('PSHELL %d has both MID1 and MID2 blank, this is not allowed.',obj.pid)
            end
            
            % Membrane
            if ~isempty(obj.mid1)
                obj.isMembrane = true;
                membraneMaterial = model.material.getMaterial(obj.mid1,model,'Mat1');
                obj.rho = membraneMaterial.rho;
                obj.E2dMembrane = membraneMaterial.E2D;
            else
                obj.isMembrane = false;
            end
            
            % Plate bending and shear
            if ~isempty(obj.mid2)
                obj.isPlate = true;
                if obj.mid2 == -1
                    error('TODO: Plane Strain analysis');
                end
                bendMaterial = model.material.getMaterial(obj.mid2,model,'Mat1');
                obj.E2dBend = obj.bendRatio*bendMaterial.E2D;
                
                if isempty(obj.mid3)
                    error('PSHELL %d has nonblank MID2 and blank MID3, this is not allowed. Plates withour shear flexibility are not supported.',obj.pid)
                end
                shearMaterial = model.material.getMaterial(obj.mid3,model,'Mat1');
                obj.E2dShear = obj.shearRatio*shearMaterial.E2D(3,3)*eye(2);
            else
                obj.isPlate = false;
            end
            
            if ~obj.isMembrane
                obj.rho = bendMaterial.rho;
            end
            
        end
        
    end
end

