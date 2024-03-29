% Class for isoparametric membrane-bending or plane strain triangular plate elements.
% Anthony Ricciardi
%
classdef Ctria3 < Element
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number of a PSHELL entry.
        g   % [3,1 uint32] Grid point identification numbers of connection points [G1,G2,G3].
        
        % theta or mcid
        tFlag % [logical] specifies how t is used to define thickness of element
        t     % [3,1 double] Thickness of element at grid points G1 through G3 if TFLAG=0 or []. If TFLAG=1, thickness becomes a product of Ti and the thickness on the PSHELL card.
        
        gdof % [1,18 uint32] indices of global degrees of freedom associated with the element.
        R_eg % [18 x 18 double] rotation matrix from the element reference frame to the nodal displacement reference frame.
        k_e % [18 x 18 double] element stiffness matrix in the element reference frame
        m_e % [18 x 18 double] element mass matrix in the element reference frame
        
        volume % [double] element volume
        mass % [double] element mass
        area % [double] element area ( = detJ/2)
        
        E2dMem % [3,3 double] Membrane elasticity matrix
        E2dBend % [3,3 double] Bending elasticity matrix
        E2dShear % [2,2 double] Transverse shear elasticity matrix
        
        T_e0 % [3,3 double] Transformation from basic to element reference frame
        x2D_e % [3,2 double] node xy locations in element reference frame
        
        % stress recovery data
        centerT % [double] element thickness at center point
        centerBm % [double] membrane strain-dispacement matrix at center point
        centerBp % [double] plate strain-dispacement matrix at center point
        
        isMembrane % [logical] true if property includes membrane terms
        isPlate % [logical] true if property includes plate terms
    end
    properties (Constant = true, Hidden = true)
        ELEMENT_TYPE = uint8(74); % [uint8] Element code corresponding to Nastran item codes documentation.
        VTK_CELL_CLASSNAME = 'VtkCellTriangle'; % [char] Vtk cell classname
        VTK_CELL_TYPE = uint8(5); % [uint8] VTK cell type number
        VTK_RESULT_TYPE = uint8(33); % [uint8] VTK result type number. Result items are shared with Cquad4.
        HDF5_ELEMENT_FORCE_CLASSNAME = 'Hdf5ElementForceTria3';
        HDF5_STRAIN_CLASSNAME = 'Hdf5ElementStrainTria3';
        HDF5_STRESS_CLASSNAME = 'Hdf5ElementStressTria3';
    end
    properties (Constant=true,Hidden = true)
        PAGE_TITLE = 'T R I A 3   E L E M E N T S     ( C T R I A 3 )';
        FORCE_ITEMS = {'MembraneX','MembraneY','MembraneXY','MomentX','MomentY','MomentXY','ShearX','ShearY'};
        STRESS_ITEMS = {'Location_Z1','NormalX_Z1','NormalY_Z1','ShearXY_Z1','ShearAngle_Z1','MajorPrin_Z1','MinorPrin_Z1','vonMises_Z1',...
                        'Location_Z2','NormalX_Z2','NormalY_Z2','ShearXY_Z2','ShearAngle_Z2','MajorPrin_Z2','MinorPrin_Z2','vonMises_Z2'}
        STRAIN_ITEMS = {'Location_Z1','NormalX_Z1','NormalY_Z1','ShearXY_Z1','ShearAngle_Z1','MajorPrin_Z1','MinorPrin_Z1','vonMises_Z1',...
                        'Location_Z2','NormalX_Z2','NormalY_Z2','ShearXY_Z2','ShearAngle_Z2','MajorPrin_Z2','MinorPrin_Z2','vonMises_Z2'}
    end
    properties (Constant=true,Hidden = true)
        MEMBRANE_DOF = uint8([1,2,7,8,13,14]);
        DRILLING_DOF = uint8([6,12,18]);
        PLATE_DOF =    uint8([3,4,5,9,10,11,15,16,17]);
        BEND_ROT_DOF = uint8([2,3,5,6,8,9]);
        T_PSI_THETA = [...
            1     0     0     0     0     0     0     0     0
            0     0    -1     0     0     0     0     0     0
            0     1     0     0     0     0     0     0     0
            0     0     0     1     0     0     0     0     0
            0     0     0     0     0    -1     0     0     0
            0     0     0     0     1     0     0     0     0
            0     0     0     0     0     0     1     0     0
            0     0     0     0     0     0     0     0    -1
            0     0     0     0     0     0     0     1     0];
        TZ_2_ELEMENT_DOF = [0 0 0
                            0 0 0
                            1 0 0
                           0 0 0
                           0 0 0
                           0 0 0
                            0 0 0
                            0 0 0
                            0 1 0
                           0 0 0
                           0 0 0
                           0 0 0
                            0 0 0
                            0 0 0
                            0 0 1
                           0 0 0
                           0 0 0
                           0 0 0];
    end
    methods
        function obj=assemble_sub(obj,model)
            
            % geometry Data
            n1 = model.point.getNode(obj.g(1),model);
            n2 = model.point.getNode(obj.g(2),model);
            n3 = model.point.getNode(obj.g(3),model);
            obj.gdof = [n1.gdof,n2.gdof,n3.gdof];
            x1 = n1.x_0;
            x2 = n2.x_0;
            x3 = n3.x_0;
            
            % element coordinate system
            x0 = x1;
            xe = x2 - x0; xe = xe./normCS(xe);
            ze = cross3(xe, x3 - x0); ze = ze./normCS(ze);
            ye = cross3(ze, xe); ye = ye./normCS(ye);
            T_e0 = [xe,ye,ze].';
            
            % node positions in element coordinate system
            x_e = T_e0*([x1, x2, x3] - [x0, x0, x0]);
            x2D_e = x_e(1:2,:);

            
            % Property and material
            pshell = model.property.getProperty(obj.pid,model,'Pshell');
            pshellT = pshell.t;
            if pshell.isMembrane
                obj.isMembrane = true;
                obj.E2dMem = pshell.E2dMembrane;
            else
                obj.isMembrane = false;
            end
            if pshell.isPlate
                obj.isPlate = true;
                obj.E2dBend = pshell.E2dBend;
                obj.E2dShear = pshell.E2dShear;
            else
                obj.isPlate = false;
            end
            
            % Element thickness
            if obj.tFlag
                if isempty(pshellT); error('PSHELL thinkness must be specified if PSHELL TFLAG=0.'); end
                if isempty(obj.t); error('CTRIA3 thinkness must be specified if PSHELL TFLAG=0.'); end
                tNodes = pshellT*obj.t;
            else
                if ~isempty(obj.t)
                    if isempty(pshellT); error('No shell thinkness defined. Shell thickness must be specifed on PSHELL or CTRIA3 entries.'); end
%                     tNodes = mean(obj.t);
                    tNodes = reshape(obj.t, [3,1]);
                else
                    tNodes = ones(3,1)*pshellT;
                end
            end
            
            % Shape function derivatives and Jacobian are constants
            dNdxi  = [-1, 1, 0];
            dNdeta = [-1, 0, 1];
            X = x_e(1,:); Y = x_e(2,:);
            detJ = (X(2)-X(1))*(Y(3)-Y(1)) - (X(3)-X(1))*(Y(2)-Y(1));
            invJ = (1/detJ)*[(Y(3)-Y(1)),-1*(Y(2)-Y(1));-1*(X(3)-X(1)),(X(2)-X(1))];
            area = detJ/2;
            
            % Tying points for mixed interpolation of transverse shear
            % [ert1,est2,c]=Ctria3.evaluateTyingPoints(dNdxi,dNdeta,invJ);
            
            % three-point integration
            if obj.isPlate
                w3 = 1/3; % integration weight factor
                bendingStiffness = zeros(9);
                sumBp = 0;
                transverseShearStiffness = zeros(9);
                R = [2/3 1/6 1/6];
                S = [1/6 1/6 2/3];
%                 R = [.5 0 .5];
%                 S = [0 .5 .5];
                for i = 1:3
                    % Gauss point evaluation
                    N = Ctria3.evaluateShapeFunctions(R(i),S(i));
                    
                    % Thickness at point
                    tGauss = N * tNodes;
                    
                    % Plate stiffness integration
                    Bp = Ctria3.calculateMindlinPlateB(N,dNdxi,dNdeta,invJ);
                    bendingStiffness = bendingStiffness ...
                        + w3*(tGauss^3/12)*Bp(1:3,:).'*obj.E2dBend*Bp(1:3,:)*area;
                    
                    % Average Bp for shear calculation
                    sumBp = sumBp + Bp;
                    
                    % mixed interpolation
%                     Bs = [ert1 + c*S(i); est2 - c*R(i)];
%                     transverseShearStiffness = transverseShearStiffness...
%                         + w3*Bs.'*obj.E2dShear*Bs*area *tGauss;
 
                end
            end
           
            % single-point integration
            N = Ctria3.evaluateShapeFunctions(1/3,1/3);
            obj.centerT = N * tNodes;
            if obj.isMembrane
                obj.centerBm = Ctria3.calculateMembraneB(detJ,X,Y);
                membraneStiffness = obj.centerBm.'*obj.E2dMem*obj.centerBm*area*obj.centerT;
            end
            if obj.isPlate
                
                obj.centerBp = (1/3)*sumBp;
                % obj.centerBp = Ctria3.calculateMindlinPlateB(N,dNdxi,dNdeta,invJ);
                
                % consistent interpolation
                transverseShearStiffness = obj.centerBp(4:5,:).'*obj.E2dShear*obj.centerBp(4:5,:)*area*obj.centerT;
                
                % mixed interpolation
%                 Bs = [ert1 + c*(1/3); est2 - c*(1/3)];
%                 transverseShearStiffness = Bs.'*obj.E2dShear*Bs*area*obj.centerT;
            end
            
            % element stiffness matrix
            obj.k_e = zeros(18);
            if obj.isMembrane
                obj.k_e(obj.MEMBRANE_DOF,obj.MEMBRANE_DOF) = membraneStiffness;
                
                % drilling stiffness
                % Nastran Element User's guide equation for CQUAD8 and CTRIA6
                % krot = model.k6rot/1e6 * (obj.E2dBend(1,1)+obj.E2dBend(2,2))
                
                % reverse engineered equation for CQUAD4 K(6,6)
                krot = model.k6rot/1e7 * obj.E2dMem(3,3);
                
                % Application similar to Zienkiewicz approach as documented
                % in 16.4-2 in CMPW Eq. 16.4-2.
                obj.k_e(obj.DRILLING_DOF,obj.DRILLING_DOF) = krot*[  1,-.5,-.5;
                                                                   -.5,  1,-.5;
                                                                   -.5,-.5,  1];
            end
            if obj.isPlate
                % shear correction factor inspired by Tessler and Hughes MIN3 approach
                alpha = (1/pshell.shearRatio)*...
                        trace(transverseShearStiffness(obj.BEND_ROT_DOF,obj.BEND_ROT_DOF))/...
                        trace(bendingStiffness(obj.BEND_ROT_DOF,obj.BEND_ROT_DOF));
                phi2 = 1/(1+3*alpha); % equivalent to C = 1/6 - different than MIN3 optimium
                obj.k_e(obj.PLATE_DOF,obj.PLATE_DOF) = bendingStiffness + phi2*transverseShearStiffness;
            end
            
            % element total mass and volume
            obj.volume = area*obj.centerT;
            obj.mass   = obj.volume*pshell.rho + area*pshell.nsm;
            
            % consistent mass matrix
            mm  = obj.mass*(1/9)*ones(3);
            me = zeros(18);
            mi1 = 1:6:18;
            mi2 = 2:6:18;
            mi3 = 3:6:18;
            me(mi1,mi1) = me(mi1,mi1) + mm;
            me(mi2,mi2) = me(mi2,mi2) + mm;
            me(mi3,mi3) = me(mi3,mi3) + mm;
            % lumped mass matrix
            if ~model.coupledMassFlag
                me = diag(sum(me,2));
            end
            obj.m_e = me;
            
            % Transformation matrix
            obj.R_eg(16:18,16:18) = T_e0*n3.T_g0.';
            obj.R_eg(13:15,13:15) = T_e0*n3.T_g0.';
            obj.R_eg(10:12,10:12) = T_e0*n2.T_g0.';
            obj.R_eg(7:9,7:9)     = T_e0*n2.T_g0.';
            obj.R_eg(4:6,4:6)     = T_e0*n1.T_g0.';
            obj.R_eg(1:3,1:3)     = T_e0*n1.T_g0.';
            
            % save select properties
            obj.area = area;
            obj.T_e0 = T_e0;
            obj.x2D_e = x2D_e;
        end

        function kd_e = assembleKD(obj, model, staticsSolution)
            % Assemble element differential stiffness matrix
            %
            % Inputs
            % obj [Ctria3]
            % model [Model]
            % staticsSolution [StaticsSolution]
            %
            % Outputs
            % kd_e [18,18 double] element differential stiffness matrix in the element reference frame

            % In plane force from reference solution
            if isempty(staticsSolution.force); error('CTRIA3 element differential stiffness calculation requires element force data from reference solution.'); end
            forceIndex = find([staticsSolution.force.elementID]==obj.eid); % This line may be inefficient for large models.
            if length(forceIndex)~=1; error('There is an issue locating element force data for CQUAD4 element differential stiffness calculation'); end
            referenceForce = staticsSolution.force(forceIndex);
            if referenceForce.elementType~=74; error('There is an issue locating element force data for CTRIA3 element differential stiffness calculation'); end
            f = referenceForce.values(1:3);
            T_gp = [[f(1), f(3)];
                    [f(3), f(2)]];

            % Gauss quadrature points and weights
            gauss_weight = 0.5;

            % Initialize geometric stiffness matrix (18x18)
            kd_e = zeros(18);
            w_inds = obj.PLATE_DOF(1:3:9);

            % G matrix components
            dN_dxi  = [-1,1,0];
            dN_deta = [-1,0,1];
            [~, detJ, invJ] = Ctria3.calculateJacobian2D(dN_dxi, dN_deta, obj.x2D_e);
            G_e = invJ*[dN_dxi; dN_deta];
           
            % Assemble geometric stiffness matrix at the current Gauss point
            kd_e_gp = G_e'*T_gp*G_e;
            kd_e(w_inds,w_inds) = kd_e(w_inds,w_inds) + gauss_weight*kd_e_gp*detJ;

        end

        function [gdof,p_g]=processPressureLoad_sub(obj,pload)
            R = [2/3 1/6 1/6];
            S = [1/6 1/6 2/3];
            w3 = 1/3; % integration weight factor
            pressureForce_e = zeros(3,1);
            for i = 1:3 
                % Gauss point evaluation
                N = Ctria3.evaluateShapeFunctions(R(i),S(i));
                                
                % pressure at point
                pGauss = N.' .* pload.p(1:3);
                
                % Pressure integration
                pressureForce_e = pressureForce_e + w3*obj.area*pGauss;
            end
            p_e = obj.TZ_2_ELEMENT_DOF*pressureForce_e;
            p_g = obj.R_eg.'*p_e;
            gdof = obj.gdof; 
        end
        
        function [force,stress,strain,strainEnergy,kineticEnergy] = recover_sub(obj,u_g,model,returnFlags)
            % INPUTS
            % u_g [nGodf,nVectors double] Response vector in nodal displacement reference frame
            % returnFlags [1,5 logical] [force,stress,strain,strainEnergy,kineticEnergy] 1 -> recover, 0 -> return empty array []
            %
            % OUTPUTS
            % force = [14,nVectors double] Element forces
            %   indices:
            %    [1 |  Membrane force x
            %     2 |  Membrane force y
            %     3 |  Membrane force xy
            %     4 |  Bending moment x
            %     5 |  Bending moment y
            %     6 |  Bending moment xy
            %     7 |  Shear x
            %     8 |  Shear y           ]
            %
            % stress  = [8,nVectors double] Element stresses
            % strain  = [8,nVectors double] Element strains
            %   indices:
            %    [1 |  Z1=Fiber Distance 1
            %     2 |  Normal x at Z1
            %     3 |  Normal y at Z1
            %     4 |  Shear xy at Z1
            %     5 |  Shear angle at Z1
            %     6 |  Major principal at Z1
            %     7 |  Minor principal at Z1
            %     8 |  von Mises or maximum shear at Z1
            %     9 |  Z2=Fiber Distance 2
            %    10 |  Normal x at Z2
            %    11 |  Normal y at Z2
            %    12 |  Shear xy at Z2
            %    13 |  Shear angle at Z2
            %    14 |  Major principal at Z2
            %    15 |  Minor principal at Z2
            %    16 |  von Mises or maximum shear at Z2    ]
            %
            % strainEnergy  = [3,nVectors double] Element strain energy
            % kineticEnergy = [3,nVectors double] Element kinetic energy
            %   indices:
            %    [ energy
            %      energy----------> converted to percent total later by Element.recover()
            %      energyDensity];
            %  kineticEnergy scaled by omega later by Element.recover()
            
            
            
            % Check inputs
            if ~any(returnFlags); error('This function is not intended to be called if no vaules are to be recovered'); end
            
            % Element displacements
            u_e = obj.R_eg*u_g(obj.gdof,:);
            nVectors = size(u_e,2);
            
            % Membrane values
            if obj.isMembrane
                membraneStrain = obj.centerBm*u_e(obj.MEMBRANE_DOF,:);
                membraneForce = obj.centerT*obj.E2dMem*membraneStrain;
            else
                membraneStrain = zeros(3,nVectors);
                membraneForce = zeros(3,nVectors);
            end
            
            % Plate values
            if obj.isPlate
                plateCurvature = obj.centerBp*u_e(obj.PLATE_DOF,:);
                plateMoment = (obj.centerT^3/12)*obj.E2dBend*plateCurvature(1:3,:);
                plateShear = obj.E2dShear*plateCurvature(4:5,:);
            else
                plateCurvature = zeros(5,nVectors);
                plateMoment = zeros(3,nVectors);
                plateShear = zeros(2,nVectors);
            end
            
            % Force
            if returnFlags(1)
                force = zeros(8,nVectors);
                force(1:3,:) = membraneForce;
                force(4:6,:) = plateMoment;
                force(7:8,:) = plateShear;
            else
                force = [];
            end
            
            % stress or strain data
            if any(returnFlags(2:3))
                z = obj.centerT/2;
            end
            
            % Stress
            if returnFlags(2)
                membraneStress = (1/obj.centerT)*membraneForce;
                bendingStress = (6/obj.centerT^2)*plateMoment; 
                topStress    = membraneStress - bendingStress;
                bottomStress = membraneStress + bendingStress;
                
                vonMisesT = calculateVonMises(topStress);
                vonMisesB = calculateVonMises(bottomStress);
                
                [s1T,s2T,angleT] = calculatePrincipal(topStress);
                [s1B,s2B,angleB] = calculatePrincipal(bottomStress);
                
                stress = [
                    -z*ones(1,nVectors);
                    bottomStress(1,:)
                    bottomStress(2,:)
                    bottomStress(3,:)
                    angleB
                    s1B
                    s2B
                    vonMisesB
                    z*ones(1,nVectors);
                    topStress(1,:)
                    topStress(2,:)
                    topStress(3,:)
                    angleT
                    s1T
                    s2T
                    vonMisesT];
            else
                stress = [];
            end
            
            % Strain
            if returnFlags(3)
                topStrain    = membraneStrain - z*plateCurvature(1:3,:);
                bottomStrain = membraneStrain + z*plateCurvature(1:3,:);
                
                vonMisesT = calculateVonMises(topStrain);
                vonMisesB = calculateVonMises(bottomStrain);
                
                [s1T,s2T,angleT] = calculatePrincipal(topStrain);
                [s1B,s2B,angleB] = calculatePrincipal(bottomStrain);
                
                strain = [
                    -z*ones(1,nVectors);
                    bottomStrain(1,:)
                    bottomStrain(2,:)
                    bottomStrain(3,:)
                    angleB
                    s1B
                    s2B
                    vonMisesB
                    z*ones(1,nVectors);
                    topStrain(1,:)
                    topStrain(2,:)
                    topStrain(3,:)
                    angleT
                    s1T
                    s2T
                    vonMisesT];
            else
                strain = [];
            end
            
            % Strain Energy
            if returnFlags(4)
                strainEnergy0 = .5*diag(u_e.'*obj.k_e*u_e).';
                strainEnergy = [strainEnergy0;
                    strainEnergy0;%---> converted to percent total later by Element.recover()
                    (1/obj.volume)*strainEnergy0];
            else
                strainEnergy = [];
            end
            
            % Kinetic Energy (scaled by omega later by Element.recover())
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
    methods (Access=private, Static=true)
        function N = evaluateShapeFunctions(r,s)
            N = [1-r-s, r, s];
        end
        function B = calculateMembraneB(detJ,X,Y)
            % Membrane strain-dispacement matrix
            % CMPW (7.2-8) fast analytic method
            B = 1/(detJ)*...
                [Y(2)-Y(3),0,Y(3)-Y(1),0,Y(1)-Y(2),0;
                0,X(3)-X(2),0,X(1)-X(3),0,X(2)-X(1);
                X(3)-X(2),Y(2)-Y(3),X(1)-X(3),Y(3)-Y(1),X(2)-X(1),Y(1)-Y(2)];
        end

        function [N,dNdxi,dNdeta] = evaluateShapeAndGradFunctions(xi,eta)
            N      = [1 - xi - eta, xi, eta];
            dNdxi  = [-1,1,0];
            dNdeta = [-1,0,1];
        end

        function [J,detJ,invJ]=calculateJacobian2D(dNdxi,dNdeta,x2D_e)
            J = [dNdxi;dNdeta]*x2D_e.';
            detJ = det(J);
            invJ=(1/detJ)*[J(2,2),-J(1,2);-J(2,1),J(1,1)];
        end

        function [quad_points, quad_weights] = triangle_quadrature(order)
            % This function returns the quadrature points and weights for the reference
            % triangle for a specified order of Gauss quadrature.
        
            switch order
                case 1
                    % Order 1 Gauss quadrature (1 point, degree of precision 1)
                    quad_points = [1/3, 1/3];
                    quad_weights = 1/2;
        
                case 2
                    % Order 2 Gauss quadrature (3 points, degree of precision 3)
                    quad_points = [2/3, 1/6;
                                   1/6, 2/3;
                                   1/6, 1/6];
                    quad_weights = [1/6, 1/6, 1/6];
        
                case 3
                    % Order 3 Gauss quadrature (4 points, degree of precision 5)
                    a = 1/3;
                    b = 3/5;
                    c = 1/5;
                    quad_points = [a, a;
                                   b, c;
                                   c, b;
                                   c, c];
                    quad_weights = [-9/32, 25/96, 25/96, 25/96];
        
                otherwise
                    error('Unsupported quadrature order. Supported orders are 1, 2, and 3.');
            end
        end

        function B = calculateMindlinPlateB(N,dNdxi,dNdeta,invJ)
            % Mindlin plate strain-dispacement matrix
            dNdxy = invJ*[dNdxi; dNdeta];
            dNdx  = dNdxy(1,:);
            dNdy  = dNdxy(2,:);
            B = [0        dNdx(1) 0       0       dNdx(2) 0       0       dNdx(3) 0
                 0        0       dNdy(1) 0       0       dNdy(2) 0       0       dNdy(3)
                 0        dNdy(1) dNdx(1) 0       dNdy(2) dNdx(2) 0       dNdy(3) dNdx(3)
                -dNdx(1)  N(1)    0      -dNdx(2) N(2)    0      -dNdx(3) N(3)    0
                -dNdy(1)  0       N(1)   -dNdy(2) 0       N(2)   -dNdy(3) 0       N(3)    ] ...
                *Ctria3.T_PSI_THETA;
        end
        function [ert1,est2,c]=evaluateTyingPoints(dNdxi,dNdeta,invJ)
            % Tying Points - Lee & Bathe (C&S 82, 2004)
            R = [.5 0 .5];
            S = [0 .5 .5];
            B1 = Ctria3.calculateMindlinPlateB(...
                               Ctria3.evaluateShapeFunctions(R(1),S(1)),...
                               dNdxi,dNdeta,invJ);
            B2 = Ctria3.calculateMindlinPlateB(...
                               Ctria3.evaluateShapeFunctions(R(2),S(2)),...
                               dNdxi,dNdeta,invJ);
            B3 = Ctria3.calculateMindlinPlateB(...
                               Ctria3.evaluateShapeFunctions(R(3),S(3)),...
                               dNdxi,dNdeta,invJ);
           ert1 = [0 0 0 1 0]*B1;
           ert3 = [0 0 0 1 0]*B3;
           est2 = [0 0 0 0 1]*B2;
           est3 = [0 0 0 0 1]*B3;
           c = est2 - ert1 - est3 + ert3;
        end
    end
end