% Class for beam elements.
% Anthony Ricciardi
%
classdef Cbeam < Element
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number of a PBEAM entry.
        g   % [2,1 uint32] Grid point identification numbers of connection points [GA,GB].
        nu_g   % [3,1 double] Components of orientation vector NU, from GA, in the nodal displacement reference frame at GA.
        
        gdof % [1,12 uint32] indices of global degrees of freedom associated with the element.
        R_eg % [12 x 12 double] rotation matrix from the element reference frame to the nodal displacement reference frame.
        k_e % [12 x 12 double] element stiffness matrix in the element reference frame
        m_e % [12 x 12 double] element mass matrix in the element reference frame
    end
    properties (Hidden = true)
        ELEMENT_TYPE = uint8(2); % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
    end
    methods
        function obj=assemble_sub(obj,model)
            
            % Geometry Data
            n1 = model.point.getNode(obj.g(1),model);
            n2 = model.point.getNode(obj.g(2),model);
            obj.gdof = [n1.gdof,n2.gdof];
            p1 = n1.x_0;
            p2 = n2.x_0;
            nu_0 = n1.T_g0.'*obj.nu_g;
            
            % Property and material data
            pty = model.property.getProperty(obj.pid,model,'Pbeam');
            
            % Element matricies
            [T_e0,obj.k_e,obj.m_e] = Cbeam.getElementMatrices(p1,p2,nu_0,...
                pty.E,pty.G,pty.a,pty.i2,pty.i1,pty.j,pty.rho,pty.nsm,...
                pty.k1,pty.k2,model.coupledMassFlag);
            
            % Transformation matrix
            obj.R_eg(10:12,10:12) = T_e0*n2.T_g0.';
            obj.R_eg(7:9,7:9)     = T_e0*n2.T_g0.';
            obj.R_eg(4:6,4:6)     = T_e0*n1.T_g0.';
            obj.R_eg(1:3,1:3)     = T_e0*n1.T_g0.';
        end
        function [force,stress,strain,strainEnergy] = recover_sub(obj,u_g,model,returnFlags)
            % INPUTS
            % u_g [nGodf,nVectors double] Response vector in nodal displacement reference frame
            % returnFlags [1,4 logical] [force,stress,strain,strain_energy] 1 -> recover, 0 -> return empty array []
            %
            % OUTPUTS
            % force = [12,nVectors double] Element forces
            %   indices:
            %    [  Beam EndA Axial Force
            %       Beam EndA Plane1 Shear Force
            %       Beam EndA Plane2 Shear Force
            %       Beam EndA Plane1 Moment
            %       Beam EndA Plane2 Moment
            %       Beam EndA Torque
            %       Beam EndB Axial Force
            %       Beam EndB Plane1 Shear Force
            %       Beam EndB Plane2 Shear Force
            %       Beam EndB Plane1 Moment
            %       Beam EndB Plane2 Moment
            %       Beam EndB Torque             ]
            %
            % stress  = [8,nVectors double] Element stresses
            % strain  = [8,nVectors double] Element strains
            %   indices:
            %    [ End A Long. Stress or Strain at Point C;
            %      End A Long. Stress or Strain at Point D;
            %      End A Long. Stress or Strain at Point E;
            %      End A Long. Stress or Strain at Point F;
            %      End B Long. Stress or Strain at Point C;
            %      End B Long. Stress or Strain at Point D;
            %      End B Long. Stress or Strain at Point E;
            %      End B Long. Stress or Strain at Point F];
            %
            % strainEnergy = [1,nVectors double] Element strain energy
            
            
            % Check inputs
            if ~any(returnFlags); error('This function is not intended to be called if no vaules are to be recovered'); end
            
            % Element displacements and forces
            u_e = obj.R_eg*u_g(obj.gdof,:);
            f_e = obj.k_e*u_e;
            
            % Force
            if returnFlags(1)
                force = [-f_e(1:6 ,:);
                          f_e(7:12,:)];
            else
                force = [];
            end
                        
            % Calcualte stress for stress or strain recovery
            if any(returnFlags(2:3))
                pty = model.property.getProperty(obj.pid,model,'Pbeam');
                [C1,C2,D1,D2,E1,E2,F1,F2]=pty.getStressLocations();
                force2stress = [1/pty.a, 0, 0, 0, C2/pty.i2, -C1/pty.i1;
                                1/pty.a, 0, 0, 0, D2/pty.i2, -D1/pty.i1;
                                1/pty.a, 0, 0, 0, E2/pty.i2, -E1/pty.i1;
                                1/pty.a, 0, 0, 0, F2/pty.i2, -F1/pty.i1];
                s = [-force2stress*f_e(1:6,:);
                      force2stress*f_e(7:end,:)];
            end
            
            % Stress
            if returnFlags(2)
                stress = s;
            else
                stress = [];
            end
            
            % Strain
            if returnFlags(3)
                strain = (1/pty.E)*s;
            else
                strain = [];
            end
            
            % Strain Energy
            if returnFlags(4)
                strainEnergy = .5*diag(u_e.'*f_e);
            else
                strainEnergy = [];
            end
        end
    end
    methods (Access=private,Static=true)
        function [T_e0,k_e,m_e] = getElementMatrices(p1,p2,nu_0,E,G,A,Iy,Iz,J,rho,nsm,k1,k2,coupledMassFlag)
            % Returns the element matrices for a space frame element
            % Constant cross-section properties are required
            % Anthony Ricciardi
            %
            % Inputs
            % p1 = [3,1 double] coordinates (x1,y1,z1) of the first node in the basic reference frame
            % p2 = [3,1 double] coordinates (x2,y2,z2) of the second node in the basic reference frame
            % nu_0 = [3,1 double] beam orientation vector in the basic reference frame
            % E [double] modulus of elasticity
            % G [double] shear modulus of elasticity
            % A [double] cross-sectional area ,
            % Iy, Iz [double]  moments of inertia
            % J [double] torsional constant
            % rho [double] material density
            % nsm [double] nonstructural mass per unit length
            % k1, k2 [double] Shear stiffness factor K in K.*A.*G for plane 1 and plane 2
            % coupledMassFlag [logical] Coupled mass provided if true, lumped mass otherwise.
            %
            % Outputs
            % T_e0 = [3,3 double] transformation matrix from the basic reference frame to the element reference frame
            % k_e = [12,12 double] element stiffness matrix in the element reference frame
            % m_e = [12,12 double] element mass matrix in the element reference frame
            
            L = normCS(p2-p1); % norm(p2-p1) is not complex-step friendly % sqrt( (p2(1)-p1(1)).^2 + (p2(2)-p1(2)).^2 + (p2(3)-p1(3)).^2 );
            
            % Transformation Matrix
            xVec = p2 - p1; xVec = xVec./normCS(xVec);
            zVec = cross3(xVec,nu_0); zVec = zVec./normCS(zVec);
            yVec = cross3(zVec,xVec); yVec = yVec./normCS(yVec);
            T_e0 = [xVec, yVec, zVec].';
            
            % Elastic Stiffness Matrix using Timoshenko beam equations
            if k1 == 0
                psiY = 0;
            else
                psiY = 12.*E.*Iz./(k1.*A.*G.*L.^2);
            end
            if k2 == 0
                psiZ = 0;
            else
                psiZ = 12.*E.*Iy./(k2.*A.*G.*L.^2);
            end
            X = E.*A./L;
            Y1 = 12.*E.*Iz./((1+psiY).*L.^3);
            Z1 = 12.*E.*Iy./((1+psiZ).*L.^3);
            Y2 = 6.*E.*Iz./((1+psiY).*L.^2);
            Z2 = 6.*E.*Iy./((1+psiZ).*L.^2);
            Y3 = (4+psiY).*E.*Iz./((1+psiY).*L);
            Z3 = (4+psiZ).*E.*Iy./((1+psiZ).*L);
            Y4 = (2-psiY).*E.*Iz./((1+psiY).*L);
            Z4 = (2-psiZ).*E.*Iy./((1+psiZ).*L);
            S = G.*J./L;
            ke11 = diag([X Y1 Z1 S Z3 Y3]);
            ke11(3,5) = -Z2; ke11(5,3) = -Z2; ke11(2,6) = Y2; ke11(6,2) = Y2;
            ke22 = diag([X Y1 Z1 S Z3 Y3]);
            ke22(3,5) = Z2; ke22(5,3) = Z2; ke22(2,6) = -Y2; ke22(6,2) = -Y2;
            ke12 = diag([-X -Y1 -Z1 -S Z4 Y4]);
            ke12(3,5) = -Z2; ke12(5,3) = Z2; ke12(2,6) = Y2; ke12(6,2) = -Y2;
            k_e = [ke11,ke12;ke12.',ke22];
            
            % Mass Matrix
            a = .5.*L;
            rx2 = 0;
            m_e = diag([70 78 78 70.*rx2 8.*a.^2 8.*a.^2 70 78 78 70.*rx2 8.*a.^2 8.*a.^2]);
            m_e(1,7) = 35;
            m_e(2,6) = 22.*a;
            m_e(2,8) = 27;
            m_e(2,12) = -13.*a;
            m_e(3,5) = -22.*a;
            m_e(3,9) = 27;
            m_e(3,11) = 13.*a;
            m_e(4,10) = -35.*rx2;
            m_e(5,9) = -13.*a;
            m_e(5,11) = -6.*a.^2;
            m_e(6,8) = 13.*a;
            m_e(6,12) = -6.*a.^2;
            m_e(8,12) = -22.*a;
            m_e(9,11) = 22.*a;
            m_e(7,1)  = m_e(1,7); m_e(6,2) = m_e(2,6); m_e(8,2) = m_e(2,8);
            m_e(12,2) = m_e(2,12); m_e(5,3) = m_e(3,5); m_e(9,3) = m_e(3,9);
            m_e(11,3) = m_e(3,11); m_e(10,4) = m_e(4,10); m_e(9,5) = m_e(5,9);
            m_e(11,5) = m_e(5,11); m_e(8,6) = m_e(6,8); m_e(12,6) = m_e(6,12);
            m_e(12,8) = m_e(8,12); m_e(11,9) = m_e(9,11);
            m_e = (rho.*A+nsm).*a./105.*m_e;
            
            % Add torsional intertia
            m_e(4,4)   = (Iz+Iy)./A.*m_e(1,1);
            m_e(4,10)  = m_e(4,4)./2;
            m_e(10,10) = m_e(4,4);
            m_e(10,4)  = m_e(4,10);
            
            if ~coupledMassFlag
                % convert to lumped mass formulation
                lumpedTranslationM_e = diag(sum(m_e([1:3,7:9],[1:3,7:9]),2));
                lumpedRotationM_e = diag(sum(m_e([4,10],[4,10]),2));
                m_e = zeros(12,12);
                m_e([1:3,7:9],[1:3,7:9]) = lumpedTranslationM_e;
                m_e([4,10],[4,10]) = lumpedRotationM_e;
            end
            
            %     % Add rotary inertia (not default)
            %     rIy = rho.*Iy./(30.*L).*[36    -3.*L    -36   -3*L;
            %                             -3.*L   4.*L.^2  3.*L -L.^2;
            %                             -36     3.*L     36    3.*L;
            %                             -3.*L  -L.^2     3.*L  4.*L.^2];
            %     rIz = rho.*Iz./(30.*L).*[36    -3.*L    -36   -3*L;
            %                             -3.*L   4.*L.^2  3.*L -L.^2;
            %                             -36     3.*L     36    3.*L;
            %                             -3.*L  -L.^2     3.*L  4.*L.^2];
            %     mR = zeros(12);
            %     mR([2,6,8,12],[2,6,8,12]) = rIz;
            %     mR([3,5,9,11],[3,5,9,11]) = rIy;
            %     m_e = m_e + mR;
            
        end
    end
    methods (Static=true)
        function femapDataBlock=force_2_FemapDataBlock1051(force,startSetID)
            % Convert array of crod element force data objects to an array of FEMAP data block 1051 objects
            % INPUTS
            % force [nele,nsets ElementOutputData] array of force data
            % startSetID [int] ID number of first output set
            %
            % Output
            % DB [2*nsets,1 db1051] array of FEMAP data block 1051 objects
            femapDataBlock = [];
            DoubleSidedContourVectorID = 0;
            out_type = 3; % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            ent_type = 8; % [int] Either nodal (7) or elemental (8) output
            compute_type = 0; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
            comp_dir = 2; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
            cent_total = true; % [logical] If 1, this vector has centroidal or nodal output.
            integer_format = false; % [logical] If True, vector contains integer rather than floating point results
            calc_warn = false; % [logical] If 1, can not linearly combine this output
            entityID =[force.elementID].';% [Nx1 int] Node/element IDs of the for results
            
            vecID = [3036,3038]; % [int] ID of output vector, must be unique in each output set
            title{1} = 'Rod Axial Force'; % [max 79 char] Output Vector title
            title{2} = 'Rod Torque';
            comp = zeros(2,20);
            comp(1,1:2) = vecID(1); % [1x20 int] IDs of the corresponding elemental corner output.
            comp(2,1:2) = vecID(2);
            
            n_response_vectors = size(force(1).values,2);
            vals = [force.values];
            
            for i = 1:n_response_vectors
                setID = startSetID+i-1;
                fvals = vals(1,i:n_response_vectors:end).';
                tvals = vals(2,i:n_response_vectors:end).';
                femapDataBlock=[femapDataBlock;FemapDataBlock1051(...
                    setID,vecID(1),title{1},comp(1,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,...
                    fvals)];
                femapDataBlock=[femapDataBlock;FemapDataBlock1051(...
                    setID,vecID(2),title{2},comp(2,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,...
                    tvals)];
            end
        end
        function femapDataBlock=stress_2_FemapDataBlock1051(stress,startSetID)
            % Convert array of crod element stress data objects to an array of FEMAP data block 1051 objects
            % INPUTS
            % stress [nele,nsets element_output_data] array of stress data
            % startSetID [int] ID number of first output set
            %
            % Output
            % DB [2*nsets,1 db1051] array of FEMAP data block 1051 objects
            femapDataBlock = [];
            DoubleSidedContourVectorID = 0;
            out_type = 4; % [int] Type of output (0=Any, 1=Disp, 2=Accel, 3=Force, 4=Stress, 5=Strain, 6=Temp, others=User)
            ent_type = 8; % [int] Either nodal (7) or elemental (8) output
            compute_type = 4; % [int] The combination type for this output vector (0=None, 1=Magnitude, 2=Average, 3=CornerAverage, 4=PrinStressA, 5=PrinStressB, 6=PrinStressC, 7=MaxShear,8=VonMises, 9=ComplexMagnitude)
            comp_dir = 2; % [int] If 1, comp[0..2] are the X,Y,Z component values. If 2, data at end of Beams. If 3, reverse data at second end of beam.
            cent_total = true; % [logical] If 1, this vector has centroidal or nodal output.
            integer_format = false; % [logical] If True, vector contains integer rather than floating point results
            calc_warn = false; % [logical] If 1, can not linearly combine this output
            entityID =[stress.elementID].';% [Nx1 int] Node/element IDs of the for results
            
            vecID = [3183,3186]; % [int] ID of output vector, must be unique in each output set
            title{1} = 'Rod Axial Stress'; % [max 79 char] Output Vector title
            title{2} = 'Rod Torsional Stress';
            comp = zeros(2,20);
            comp(1,1:2) = vecID(1); % [1x20 int] IDs of the corresponding elemental corner output.
            comp(2,1:2) = vecID(2);
            
            n_response_vectors = size(stress(1).values,2);
            vals = [stress.values];
            
            for i = 1:n_response_vectors
                setID = startSetID+i-1;
                svals = vals(1,i:n_response_vectors:end).';
                tvals = vals(2,i:n_response_vectors:end).';
                femapDataBlock=[femapDataBlock;FemapDataBlock1051(...
                    setID,vecID(1),title{1},comp(1,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,...
                    svals)];
                femapDataBlock=[femapDataBlock;FemapDataBlock1051(...
                    setID,vecID(2),title{2},comp(2,:),DoubleSidedContourVectorID,...
                    out_type,ent_type,compute_type,calc_warn,comp_dir,cent_total,...
                    integer_format,entityID,...
                    tvals)];
            end
        end
    end
end