% Class for isoparametric membrane-bending or plane strain triangular plate elements.
% Anthony Ricciardi
%
classdef Ctria3 < Element
    
    properties
        eid % [uint32] Element identification number.
        pid % [uint32] Property identification number of a PBEAM entry.
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

        Bm % [double] membrane strain-dispacement matrix
        E2Dm % [3,3 double] 2D elasticity matrix
        tAverage % [double] average thickness
        T_e0 % [3,3 double] Transformation from basic to element reference frame
    end
    properties (Constant = true, Hidden = true)
        ELEMENT_TYPE = uint8(74); % [uint8] Element code corresponding to Nastran item codes documentation.
        HDF5_ELEMENT_FORCE_CLASSNAME = 'Hdf5ElementForceTria3';
        HDF5_STRAIN_CLASSNAME = 'Hdf5ElementStrainTria3';
        HDF5_STRESS_CLASSNAME = 'Hdf5ElementStressTria3';
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
            
            % Property and material data
            pty = model.property.getProperty(obj.pid,model,'Pshell');
            E2Dm = pty.E2Dm;
            ptyT = pty.t;
            
            % thinkness data
            if obj.tFlag
                if isempty(ptyT); error('PSHELL thinkness must be specified if PSHELL TFLAG=0.'); end
                if isempty(obj.t); error('CTRIA3 thinkness must be specified if PSHELL TFLAG=0.'); end
                tAverage = mean(ptyT*obj.t);
            else
                if ~isempty(obj.t)
                    if isempty(ptyT); error('No shell thinkness defined. Shell thickness must be specifed on PSHELL or CTRIA3 entries.'); end
                    tAverage = mean(obj.t);
                else
                    tAverage = ptyT;
                end
            end
            
            
%             % B calculated using shape function evaluation
%             % Ni      = [1-xi-eta, xi, eta];
%             dNdxii  = [-1, 1, 0];
%             dNdetai = [-1, 0, 1];
%             J = [dNdxii;
%                 dNdetai ] * x_e(1:2,:).';
%             dNdxzy = J\[dNdxii;
%                 dNdetai ];
%             Bm=[dNdxzy(1,1)     0             dNdxzy(1,2)     0            dNdxzy(1,3)     0          ;
%                 0               dNdxzy(2,1)   0               dNdxzy(2,2)  0               dNdxzy(2,3);
%                 dNdxzy(2,1)     dNdxzy(1,1)   dNdxzy(2,2)     dNdxzy(1,2)  dNdxzy(2,3)     dNdxzy(1,3)];
            
            % B calculated using CMPW (7.2-8) fast analytic method
            X = x_e(1,:); Y = x_e(2,:);
            detJ = (X(2)-X(1))*(Y(3)-Y(1)) - (X(3)-X(1))*(Y(2)-Y(1));
            Bm= 1/(detJ)*...
                [Y(2)-Y(3),0,Y(3)-Y(1),0,Y(1)-Y(2),0;
                 0,X(3)-X(2),0,X(1)-X(3),0,X(2)-X(1);
                 X(3)-X(2),Y(2)-Y(3),X(1)-X(3),Y(3)-Y(1),X(2)-X(1),Y(1)-Y(2)];
             
             % membrane stiffness matrix
             area = detJ/2;
             km = Bm.'*E2Dm*Bm*tAverage*area;
             
             obj.k_e = zeros(18);
             memDof = [1,2,7,8,13,14];
             obj.k_e(memDof,memDof) = km;
                         
             % element total mass and volume
             obj.volume = area*tAverage;
             obj.mass   = obj.volume*pty.rho + area*pty.nsm;
            
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
             
             % save to properties
             obj.E2Dm=E2Dm;
             obj.Bm=Bm;
             obj.tAverage=tAverage;
             obj.T_e0 = T_e0;
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
            z = obj.tAverage/2;
            
            % Force
            if returnFlags(1)
                membraneForce = obj.tAverage*obj.E2Dm*obj.Bm*u_e([1,2,7,8,13,14],:);
                force = zeros(8,nVectors);
                force(1:3,:) = membraneForce;
            else
                force = [];
            end
            
            % Stress
            if returnFlags(2)
                membraneStress = obj.E2Dm*obj.Bm*u_e([1,2,7,8,13,14],:);
                
                vonMises = calculateVonMises(membraneStress);
                [s1,s2,angle] = calculatePrincipal(membraneStress);
                
                
                stress = [
                    -z*ones(1,nVectors);
                    membraneStress(1,:)
                    membraneStress(2,:)
                    membraneStress(3,:)
                    angle
                    s1
                    s2
                    vonMises
                    z*ones(1,nVectors);
                    membraneStress(1,:)
                    membraneStress(2,:)
                    membraneStress(3,:)
                    angle
                    s1
                    s2
                    vonMises];
                
            else
                stress = [];
            end
            
            % Strain
            if returnFlags(3)
                membraneStrain = obj.Bm*u_e([1,2,7,8,13,14],:);
                vonMises = calculateVonMises(membraneStrain);
                [s1,s2,angle] = calculatePrincipal(membraneStrain);
                
                strain = [
                    -z*ones(1,nVectors);
                    membraneStrain(1,:)
                    membraneStrain(2,:)
                    membraneStrain(3,:)
                    angle
                    s1
                    s2
                    vonMises
                    z*ones(1,nVectors);
                    membraneStrain(1,:)
                    membraneStrain(2,:)
                    membraneStrain(3,:)
                    angle
                    s1
                    s2
                    vonMises];
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
end