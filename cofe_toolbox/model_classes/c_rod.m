% Class for tension-compression-torsion elements.
% Anthony Ricciardi
%
classdef c_rod < elem
    
    properties
        EID % [int] Element identification number.
        PID % [int] Property identification number of a PROD entry.
        G % [1,2 int] Grid point identification numbers of connection points.
        
        gdof
        % T_e0 % [3  x 3 ] rotation matrix from the basic reference frame to the element reference frame
        R_eg % [12 x 12] rotation matrix from the element reference frame to the nodal displacement reference frame
        k_e % [12 x 12] element stiffness matrix in the element reference frame
        m_e % [12 x 12] element mass matrix in the element reference frame
    end
    methods
        function obj=assemble(obj,MODEL)
            
            g1ind = obj.G(1)==MODEL.nodeIDs;
            g2ind = obj.G(2)==MODEL.nodeIDs;
            n1 = MODEL.NODE(g1ind);
            n2 = MODEL.NODE(g2ind);
            obj.gdof = [MODEL.node2gdof(:,g1ind);MODEL.node2gdof(:,g2ind)];
            p1 = n1.X_P;
            p2 = n2.X_P;
            
            pty=MODEL.PROP(obj.PID==MODEL.propPIDs);
            if ~isa(pty,'p_rod');
                error('CROD EID=%d references property PID = %d, which is not type PROD. Only PROD properties are supported for CROD elements.',obj.EID,obj.PID);
            end
            mt=MODEL.MAT(pty.MID==MODEL.matMIDs);
            [T_e0,obj.k_e,obj.m_e] = obj.crodMat(p1,p2,mt.E,mt.G,pty.A,pty.J,mt.RHO,pty.NSM);
            
            obj.R_eg(10:12,10:12) = T_e0*n2.T_G0.';
            obj.R_eg(7:9,7:9)     = T_e0*n2.T_G0.';
            obj.R_eg(4:6,4:6)     = T_e0*n1.T_G0.';
            obj.R_eg(1:3,1:3)     = T_e0*n1.T_G0.';
        end
    end
    methods (Access=private,Static=true)
        function [T_e0,k_e,m_e] = crodMat(p1,p2,E,G,A,J,rho,NSM)
            % c_rod.assemble() subfunction returns the element matrices for CROD space truss element in the basic reference frame.
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
            % NSM = nonstructural mass per unit length
            %
            % Outputs
            % T_e0 = [3  x 3 ] rotation matrix from the basic reference frame to the element reference frame
            % k_e = [12 x 12] element stiffness matrix in the element reference frame
            % m_e = [12 x 12] element mass matrix in the element reference frame
            
            L = norm_cs(p2-p1); % Length
            
            % Transformation Matrix
            xVec = p2 - p1; xVec = xVec./norm_cs(xVec);
            zVec = [0;0;1];
            if sum(abs(xVec - zVec)) < .1 || sum(abs(xVec + zVec)) < .1
                zVec = [1;0;0];
            end
            yVec = cross3(zVec,xVec); yVec = yVec./norm_cs(yVec);
            zVec = cross3(xVec,yVec); zVec = zVec./norm_cs(zVec);
            
            T_e0 = [xVec, yVec, zVec].';
            
%             R(10:12,10:12) = T_e0;
%             R(7:9,7:9) = T_e0;
%             R(4:6,4:6) = T_e0;
%             R(1:3,1:3) = T_e0;
            
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

            
            if nargin > 2
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
%                 m_0 = R.'*( (1/6*(rho*A+NSM)*L)*m ) *R;
               m_e = (1/6*(rho*A+NSM)*L)*m;
            end
        end
    end
end