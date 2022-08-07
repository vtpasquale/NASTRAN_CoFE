% Class for tension-compression-torsion elements.
% Anthony Ricciardi
%
classdef Crod < Element
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number of a PROD entry.
        g % [1,2 uint32] Grid point identification numbers of connection points.
        
        gdof
        % T_e0 % [3 x 3 double] rotation matrix from the basic reference frame to the element reference frame
        R_eg % [12 x 12 double] rotation matrix from the element reference frame to the nodal displacement reference frame
        k_e % [12 x 12 double] element stiffness matrix in the element reference frame
        m_e % [12 x 12 double] element mass matrix in the element reference frame
        
        volume % [double] element volume
        mass % [double] element mass
        
        a % [double] Area of the rod.
        j % [double] Torsional constant.
        c % [double] Coefficient to determine torsional stress.
    end
    properties (Constant=true,Hidden = true)
        ELEMENT_TYPE = uint8(1); % [uint8] Nastran element code corresponding to Nastran item codes documentation
        VTK_CELL_CLASSNAME = 'VtkCellLine'; % [char] Vtk cell classname
        VTK_CELL_TYPE = uint8(3); % [uint8] VTK cell type number
        VTK_RESULT_TYPE = uint8(1); % [uint8] VTK result type number. Same as ELEMENT_TYPE unless result items are shared across ELEMENT_TYPEs.
        HDF5_ELEMENT_FORCE_CLASSNAME = 'Hdf5ElementForceRod';
        HDF5_STRAIN_CLASSNAME = 'Hdf5ElementStrainRod';
        HDF5_STRESS_CLASSNAME = 'Hdf5ElementStressRod';
    end
    properties (Constant=true,Hidden = true)
        PAGE_TITLE = 'R O D   E L E M E N T S     ( C R O D )';
        FORCE_ITEMS = {'Axial','Torsion'};
        STRESS_ITEMS = {'Axial','Torsion'};
        STRAIN_ITEMS = {'Axial','Torsion'};
    end
    properties (Hidden = true)
        E % [double] Elastic modulus
        G % [double] Shear modulus
    end
    methods
        function obj=assemble_sub(obj,model)
            
            % Geometry Data
            n1 = model.point.getNode(obj.g(1),model);
            n2 = model.point.getNode(obj.g(2),model);
            obj.gdof = [n1.gdof,n2.gdof];
            p1 = n1.x_0;
            p2 = n2.x_0;
            
            % Property and material data
            pty = model.property.getProperty(obj.pid,model,'Prod');
            obj.a = pty.a;
            obj.j = pty.j;
            obj.c = pty.c;
            obj.G = pty.G;
            obj.E = pty.E;
            
            % Element matricies
            [T_e0,obj.k_e,obj.m_e,obj.volume,obj.mass] = ...
                obj.crodMat(p1,p2,pty.E,pty.G,pty.a,pty.j,pty.rho,...
                            pty.nsm,model.coupledMassFlag);
            
            % Transformation matrix
            obj.R_eg(10:12,10:12) = T_e0*n2.T_g0.';
            obj.R_eg(7:9,7:9)     = T_e0*n2.T_g0.';
            obj.R_eg(4:6,4:6)     = T_e0*n1.T_g0.';
            obj.R_eg(1:3,1:3)     = T_e0*n1.T_g0.';
        end
        function [force,stress,strain,strainEnergy,kineticEnergy] = recover_sub(obj,u_g,model,returnFlags)
            % INPUTS
            % u_g [ngodf,nvectors double] Response vector in nodal displacement reference frame
            % returnFlags [1,5 logical] [force,stress,strain,strainEnergy,kineticEnergy] 1 -> recover, 0 -> return empty array []
            %
            % OUTPUTS
            % force(1,nvectors) = Axial force
            % force(2,nvectors) = Torsional moment
            % stress(1,nvectors) = Axial stress
            % stress(2,nvectors) = Torsional stress
            % strain(1,nvectors) = Axial strain
            % strain(2,nvectors) = Torsional strain
            % strainEnergy(3,nvectors) = element strain energy
            % kineticEnergy(3,nvectors) = element kinetic energy
            
            % Check inputs
            if ~any(returnFlags); error('This function is not intended to be called if no vaules are to be recovered'); end
            
            % Element displacements and forces
            u_e = obj.R_eg*u_g(obj.gdof,:);
            f_e = obj.k_e*u_e;
            
            % Force
            if returnFlags(1)
                force = [f_e(7,:);f_e(10,:)];
            else
                force = [];
            end
            
            % Calcualte stress for stress or strain recovery
            if any(returnFlags(2:3))
                s = [(1/obj.a)*f_e(7,:);...
                    (obj.c/obj.j)*f_e(10,:)];
            end
            
            % Stress
            if returnFlags(2)
                stress = s;
            else
                stress = [];
            end
            
            % Strain
            if returnFlags(3)
                strain(2,:) = (1/obj.G)*s(2,:);
                strain(1,:) = (1/obj.E)*s(1,:);
            else
                strain = [];
            end
            
            % Strain Energy
            if returnFlags(4)
                strainEnergy0 = .5*diag(u_e.'*f_e).';
                strainEnergy = [strainEnergy0;
                                strainEnergy0;%---> converted to percent total later by Element.recover()
                                (1/obj.volume)*strainEnergy0];
            else
                strainEnergy = [];
            end
            
            % Kinetic Energy
            if returnFlags(5)
                kineticEnergy0 = .5*diag(u_e.'*obj.m_e*u_e).';
                kineticEnergy = [kineticEnergy0;
                                 kineticEnergy0;%---> converted to percent total later by Element.recover()
                                 (1/obj.volume)*kineticEnergy0];
            else
                kineticEnergy = [];
            end
        end
    end
    methods (Access=private,Static=true)
        function [T_e0,k_e,m_e,volume,mass] = crodMat(p1,p2,E,G,A,J,rho,nsm,coupledMassFlag)
            % Function returns the element stiffness, mass, and rotation matrices for CROD space truss elements.
            % Anthony Ricciardi
            %
            % Inputs
            % p1 = [3x1] coordinates (x1,y1,z1) for the first node in the basic reference frame
            % p2 = [3x1] coordinates (x2,y2,z2) for the second node basic reference frame
            % E = modulus of elasticity
            % G = shear modulus of elasticity
            % A = cross-sectional area
            % J = torsional constant
            % rho = material density
            % nsm = nonstructural mass per unit length
            % coupledMassFlag [logical] Coupled mass provided if true, lumped mass otherwise.
            %
            % Outputs
            % T_e0 = [3,3 double] Transformation matrix from the basic reference frame to the element reference frame
            % k_e = [12,12 double] element stiffness matrix in the element reference frame
            % m_e = [12,12 double] element mass matrix in the element reference frame
            % volume [double] element volume
            % mass [double] element mass
            
            L = normCS(p2-p1); % Length
            
            % Transformation Matrix
            xVec = p2 - p1; xVec = xVec./normCS(xVec);
            zVec = [0;0;1];
            if sum(abs(xVec - zVec)) < .1 || sum(abs(xVec + zVec)) < .1
                zVec = [1;0;0];
            end
            yVec = cross3(zVec,xVec); yVec = yVec./normCS(yVec);
            zVec = cross3(xVec,yVec); zVec = zVec./normCS(zVec);
            T_e0 = [xVec, yVec, zVec].';
            
            % Elastic Stiffness Matrix
            k_e = zeros(12);
            k_e(1,1) = E.*A./L;
            k_e(7,7) = E.*A./L;
            k_e(1,7) =-E.*A./L;
            k_e(7,1) =-E.*A./L;
            k_e(4,4) = G.*J./L;
            k_e(10,10) = G.*J./L;
            k_e(4,10) =-G.*J./L;
            k_e(10,4) =-G.*J./L;
            
            % Mass Matrix
            m = [...
                2.5         0         0         0         0         0        .5         0         0         0         0         0
                0         3         0         0         0         0         0         0         0         0         0         0
                0         0         3         0         0         0         0         0         0         0         0         0
                0         0         0         0         0         0         0         0         0         0         0         0
                0         0         0         0         0         0         0         0         0         0         0         0
                0         0         0         0         0         0         0         0         0         0         0         0
                .5         0         0         0         0         0       2.5         0         0         0         0         0
                0         0         0         0         0         0         0         3         0         0         0         0
                0         0         0         0         0         0         0         0         3         0         0         0
                0         0         0         0         0         0         0         0         0         0         0         0
                0         0         0         0         0         0         0         0         0         0         0         0
                0         0         0         0         0         0         0         0         0         0         0         0];
            m_e = (1/6*(rho*A+nsm)*L)*m;
            
            if ~coupledMassFlag
                % convert to lumped mass
                m_e = diag(sum(m_e,2));
            end
            
            % Volume and mass
            volume = L*A;
            mass = volume*rho;
            
        end
    end
end