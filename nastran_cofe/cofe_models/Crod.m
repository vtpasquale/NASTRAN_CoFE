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
        ELEMENT_TYPE = uint8(1); % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
        HDF5_ELEMENT_FORCE_CLASSNAME = 'Hdf5ElementForceRod';
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
                obj.crodMat(p1,p2,pty.E,pty.G,pty.a,pty.j,pty.rho,pty.nsm);
            
            % Transformation matrix
            obj.R_eg(10:12,10:12) = T_e0*n2.T_g0.';
            obj.R_eg(7:9,7:9)     = T_e0*n2.T_g0.';
            obj.R_eg(4:6,4:6)     = T_e0*n1.T_g0.';
            obj.R_eg(1:3,1:3)     = T_e0*n1.T_g0.';
        end
        function [force,stress,strain,strainEnergy] = recover_sub(obj,u_g,model,returnFlags)
            % INPUTS
            % u_g [ngodf,nvectors double] Response vector in nodal displacement reference frame
            % returnFlags [1,4 logical] [force,stress,strain,strain_energy] 1 -> recover, 0 -> return empty array []
            %
            % OUTPUTS
            % force(1,nvectors) = Axial force
            % force(2,nvectors) = Torsional moment
            % stress(1,nvectors) = Axial stress
            % stress(2,nvectors) = Torsional stress
            % strain(1,nvectors) = Axial strain
            % strain(2,nvectors) = Torsional strain
            % strainEnergy(1,nvectors) = element
            
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
                strainEnergy = .5*diag(u_e.'*f_e).';
            else
                strainEnergy = [];
            end
        end
        function printTextOutput(obj,fid,elementOutputData,outputHeading)
            if ~all([elementOutputData.elementType]==obj(1).ELEMENT_TYPE)
                error('This function should only be called for ELEMENT_TYPE = %d',obj(1).ELEMENT_TYPE)
            end
            
            nCrod = size(elementOutputData,1);
            nModes = size(elementOutputData(1).values,2);
            IDs = double([elementOutputData.elementID]');
            
            % response type - [uint8] CoFE code specifying response type [1=FORCE,2=STRESS,3=STRAIN,4=STRAIN ENERGY,5=KINETIC ENERGY]
            responseType = unique([elementOutputData.responseType]);
            if size(responseType,2)~=1; error('The function should only be called for a single type of data.'); end
            
            % reshape data for printing
            values = [elementOutputData.values];
            switch responseType
                case {1 2 3}
                    axial = reshape(values(1,:),nCrod,nModes);
                    torsional = reshape(values(2,:),nCrod,nModes);
                otherwise
                    energy = values;
            end
            
            for m = 1:nModes
                
                outputHeading.printTextOutput(fid,m)
                
                switch responseType
                    case 1 % FORCE
                        fprintf(fid,'\n\n   F O R C E S   I N   R O D   E L E M E N T S     ( C R O D )\n');
                        fprintf(fid,'       ELEMENT       AXIAL        TORQUE\n');
                        fprintf(fid,'           ID.       FORCE\n');
                        fprintf(fid,'%14d%15E%15E\n',[IDs,axial(:,m),torsional(:,m)]');
                        
                    case 2 % STRESS
                        fprintf(fid,'\n\n   S T R E S S E S   I N   R O D   E L E M E N T S      ( C R O D )\n');
                        fprintf(fid,'       ELEMENT       AXIAL        TORSIONAL\n');
                        fprintf(fid,'           ID.      STRESS         STRESS\n');
                        fprintf(fid,'%14d%15E%15E\n',[IDs,axial(:,m),torsional(:,m)]');

                    case 3 % STRAIN
                        
                    case 4 % STRAIN ENERGY
                        
                    case 5 % KINETIC ENERGY
                        
                    otherwise
                        error('Element responseType=%d not supported.',responseType)
                end
            end
            
        end        
    end
    methods (Access=private,Static=true)
        function [T_e0,k_e,m_e,volume,mass] = crodMat(p1,p2,E,G,A,J,rho,nsm)
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
            
            % Volume and mass
            volume = L*A;
            mass = volume*rho;
            
        end
    end
end