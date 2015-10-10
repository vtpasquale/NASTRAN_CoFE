% Function returns the element stiffness matrix for a space frame element in the global reference frame
% Constant cross-section properties are required
% Anthony Ricciardi
%
% Inputs
% p1 = [3x1] coordinates (x1,y1,z1) for the first node
% p2 = [3x1] coordinates (x2,y2,z2) for the second node
% nuVec = [3x1] beam orientation vector
% E = modulus of elasticity 
% G = shear modulus of elasticity 
% A = cross-sectional area , 
% Iy and Iz =  moments of inertia
% J = torsional constant
% rho = material density
% NSM = nonstructural mass per unit length
% K1, K2 Shear stiffness factor K in K.*A.*G for plane 1 and plane 2
%
% Outputs
% R = [12 x 12] rotation matrix from element frame to global frame
% ke_g = [12 x 12] element stiffness matrix in the global frame
% me_g = [12 x 12] element mass matrix in the global frame
%
% % Components of differential stiffness matrix (all in global frame)
% kdxx_g = [12 x 12] element differential stiffness matrix
%
function [R,ke_g,me_g,kdp_g,kdvy_g,kdvz_g,kdmy2_g,kdmz2_g,kdmx_g] = cbeamMat(p1,p2,nuVec,E,G,A,Iy,Iz,J,rho,NSM,K1,K2)

L = norm_cs(p2-p1); % norm(p2-p1) is not complex step friendly % sqrt( (p2(1)-p1(1)).^2 + (p2(2)-p1(2)).^2 + (p2(3)-p1(3)).^2 ); 
%% Direction Cosine Matrix
xVec = p2 - p1; xVec = xVec./norm_cs(xVec);
% cross() is more expensive than is should be.  Use specific version for 3x3
zVec = cross3(xVec,nuVec); zVec = zVec./norm_cs(zVec);
yVec = cross3(zVec,xVec); yVec = yVec./norm_cs(yVec);

Lambda = [xVec, yVec, zVec].';

R(10:12,10:12) = Lambda;
R(7:9,7:9) = Lambda;
R(4:6,4:6) = Lambda;
R(1:3,1:3) = Lambda;

%% Elastic Stiffness Matrix

% Timoshenko beam equations
if K1 == 0
    psiY = 0;
else
    psiY = 12.*E.*Iz./(K1.*A.*G.*L.^2);
end
if K2 == 0
    psiZ = 0;
else
    psiZ = 12.*E.*Iy./(K2.*A.*G.*L.^2);
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
% syms X Y1 Z1 S Z3 Y3 Z2 Y2 Z4 Y4
ke11 = diag([X Y1 Z1 S Z3 Y3]); 
ke11(3,5) = -Z2; ke11(5,3) = -Z2; ke11(2,6) = Y2; ke11(6,2) = Y2; 
ke22 = diag([X Y1 Z1 S Z3 Y3]); 
ke22(3,5) = Z2; ke22(5,3) = Z2; ke22(2,6) = -Y2; ke22(6,2) = -Y2; 
ke12 = diag([-X -Y1 -Z1 -S Z4 Y4]); 
ke12(3,5) = -Z2; ke12(5,3) = Z2; ke12(2,6) = Y2; ke12(6,2) = -Y2; 
ke_g = R.'*[ke11,ke12;ke12.',ke22]*R;


% % Euler_bernoulli
% R.'*...
%     [E.*A./L	0	0	0	0	0	-(E.*A./L)	0	0	0	0	0
%     0	(12.*E.*Iz)./L.^3	0	0	0	(6.*E.*Iz)./L.^2	0	-((12.*E.*Iz)./L.^3)	0	0	0	(6.*E.*Iz)./L.^2
%     0	0	(12.*E.*Iy)./L.^3	0	-((6.*E.*Iy)./L.^2)	0	0	0	-((12.*E.*Iy)./L.^3)	0	-((6.*E.*Iy)./L.^2)	0
%     0	0	0	G.*J./L	0	0	0	0	0	-(G.*J./L)	0	0
%     0	0	-((6.*E.*Iy)./L.^2)	0	(4.*E.*Iy)./L	0	0	0	(6.*E.*Iy)./L.^2	0	(2.*E.*Iy)./L	0
%     0	(6.*E.*Iz)./L.^2	0	0	0	(4.*E.*Iz)./L	0	-((6.*E.*Iz)./L.^2)	0	0	0	(2.*E.*Iz)./L
%     -(E.*A./L)	0	0	0	0	0	E.*A./L	0	0	0	0	0
%     0	-((12.*E.*Iz)./L.^3)	0	0	0	-((6.*E.*Iz)./L.^2)	0	(12.*E.*Iz)./L.^3	0	0	0	-((6.*E.*Iz)./L.^2)
%     0	0	-((12.*E.*Iy)./L.^3)	0	(6.*E.*Iy)./L.^2	0	0	0	(12.*E.*Iy)./L.^3	0	(6.*E.*Iy)./L.^2	0
%     0	0	0	-(G.*J./L)	0	0	0	0	0	G.*J./L	0	0
%     0	0	-((6.*E.*Iy)./L.^2)	0	(2.*E.*Iy)./L	0	0	0	(6.*E.*Iy)./L.^2	0	(4.*E.*Iy)./L	0
%     0	(6.*E.*Iz)./L.^2	0	0	0	(2.*E.*Iz)./L	0	-((6.*E.*Iz)./L.^2)	0	0	0	(4.*E.*Iz)./L]...
%     .*R;

%% Mass Matrix
if nargout > 2
    a = .5.*L;
    rx2 = 0;
    
    mprime = diag([70 78 78 70.*rx2 8.*a.^2 8.*a.^2 70 78 78 70.*rx2 8.*a.^2 8.*a.^2]);
    mprime(1,7) = 35;
    mprime(2,6) = 22.*a;
    mprime(2,8) = 27;
    mprime(2,12) = -13.*a;
    mprime(3,5) = -22.*a;
    mprime(3,9) = 27;
    mprime(3,11) = 13.*a;
    mprime(4,10) = -35.*rx2;
    mprime(5,9) = -13.*a;
    mprime(5,11) = -6.*a.^2;
    mprime(6,8) = 13.*a;
    mprime(6,12) = -6.*a.^2;
    mprime(8,12) = -22.*a;
    mprime(9,11) = 22.*a;
    
    mprime(7,1) = mprime(1,7); mprime(6,2) = mprime(2,6); mprime(8,2) = mprime(2,8);
    mprime(12,2) = mprime(2,12); mprime(5,3) = mprime(3,5); mprime(9,3) = mprime(3,9);
    mprime(11,3) = mprime(3,11); mprime(10,4) = mprime(4,10); mprime(9,5) = mprime(5,9);
    mprime(11,5) = mprime(5,11); mprime(8,6) = mprime(6,8); mprime(12,6) = mprime(6,12);
    mprime(12,8) = mprime(8,12); mprime(11,9) = mprime(9,11);

    mprime = (rho.*A+NSM).*a./105.*mprime;
    
    % Add torsional intertia
    % I_xx./Area.*axial_mass
    % if mprime(4,4) ~= 0; error('add logic for this'); end
    mprime(4,4)   = (Iz+Iy)./A.*mprime(1,1);
    mprime(4,10)  = mprime(4,4)./2;
    mprime(10,10) = mprime(4,4);
    mprime(10,4)  = mprime(4,10);
    
    
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
%     mprime = mprime + mR;
                        
    % Global Frame
    me_g = R.'*mprime*R;
end

%% Differential Stiffness Matrices
if nargout > 3
    r2 = (Iz+Iy)./A;
    
    kdp_g = R.'*...
        [0	0	0	0	0	0	0	0	0	0	0	0
        0	6./(5.*L)	0	0	0	1./10	0	-(6./(5.*L))	0	0	0	1./10
        0	0	6./(5.*L)	0	-(1./10)	0	0	0	-(6./(5.*L))	0	-(1./10)	0
        0	0	0	r2./L	0	0	0	0	0	-(r2./L)	0	0
        0	0	-(1./10)	0	(2.*L)./15	0	0	0	1./10	0	-(L./30)	0
        0	1./10	0	0	0	(2.*L)./15	0	-(1./10)	0	0	0	-(L./30)
        0	0	0	0	0	0	0	0	0	0	0	0
        0	-(6./(5.*L))	0	0	0	-(1./10)	0	6./(5.*L)	0	0	0	-(1./10)
        0	0	-(6./(5.*L))	0	1./10	0	0	0	6./(5.*L)	0	1./10	0
        0	0	0	-(r2./L)	0	0	0	0	0	r2./L	0	0
        0	0	-(1./10)	0	-(L./30)	0	0	0	1./10	0	(2.*L)./15	0
        0	1./10	0	0	0	-(L./30)	0	-(1./10)	0	0	0	(2.*L)./15]*R;
    
    kdvy_g = R.'*...
        [0      -1./L         0         0         0         0         0       1./L         0         0         0         0
      -1./L         0         0         0         0         0       1./L         0         0         0         0         0
         0         0         0        -1         0         0         0         0         0         0         0         0
         0         0        -1         0     1.*L./3         0         0         0         1         0     1.*L./6         0
         0         0         0     1.*L./3         0         0         0         0         0     1.*L./6         0         0
         0         0         0         0         0         0         0         0         0         0         0         0
         0       1./L         0         0         0         0         0      -1./L         0         0         0         0
       1./L         0         0         0         0         0      -1./L         0         0         0         0         0
         0         0         0         1         0         0         0         0         0         0         0         0
         0         0         0         0     1.*L./6         0         0         0         0         0    -1.*L./6         0
         0         0         0     1.*L./6         0         0         0         0         0    -1.*L./6         0         0
         0         0         0         0         0         0         0         0         0         0         0         0]...
         *R;

    kdvz_g = R.'*...
        [0         0      -1./L         0         0         0         0         0       1./L         0         0         0
         0         0         0         1         0         0         0         0         0         0         0         0
      -1./L         0         0         0         0         0       1./L         0         0         0         0         0
         0         1         0         0         0     1.*L./3         0        -1         0         0         0     1.*L./6
         0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0     1.*L./3         0         0         0         0         0     1.*L./6         0         0
         0         0       1./L         0         0         0         0         0      -1./L         0         0         0
         0         0         0        -1         0         0         0         0         0         0         0         0
       1./L         0         0         0         0         0      -1./L         0         0         0         0         0
         0         0         0         0         0     1.*L./6         0         0         0         0         0    -1.*L./6
         0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0     1.*L./6         0         0         0         0         0    -1.*L./6         0         0]...
         *R;

    kdmy2_g = R.'*...
        [0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0      -1./L         0         0         0         0         0       1./L         0         0
         0         0         0         0         0         0         0         0         0         0         0         0
         0      -1./L         0         0         0   -0.5000         0       1./L         0         0         0         0
         0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0   -0.5000         0         0         0         0         0         0         0         0
         0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0       1./L         0         0         0         0         0      -1./L         0         0
         0         0         0         0         0         0         0         0         0         0         0         0
         0       1./L         0         0         0         0         0      -1./L         0         0         0    0.5000
         0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0         0         0         0         0         0         0    0.5000         0         0]...
         *R;
    
    kdmz2_g = R.'*...
       [0         0         0         0         0         0         0         0         0         0         0         0
        0         0         0         0         0         0         0         0         0         0         0         0
        0         0         0      -1./L         0         0         0         0         0       1./L         0         0
        0         0      -1./L         0       1./2         0         0         0       1./L         0         0         0
        0         0         0       1./2         0         0         0         0         0         0         0         0
        0         0         0         0         0         0         0         0         0         0         0         0
        0         0         0         0         0         0         0         0         0         0         0         0
        0         0         0         0         0         0         0         0         0         0         0         0
        0         0         0       1./L         0         0         0         0         0      -1./L         0         0
        0         0       1./L         0         0         0         0         0      -1./L         0      -1./2         0
        0         0         0         0         0         0         0         0         0      -1./2         0         0
        0         0         0         0         0         0         0         0         0         0         0         0]...
        *R;
    
    kdmx_g =  R.'*...
        [0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0         0       1./L         0         0         0         0         0      -1./L         0
         0         0         0         0         0       1./L         0         0         0         0         0      -1./L
         0         0         0         0         0         0         0         0         0         0         0         0
         0       1./L         0         0         0         0         0      -1./L         0         0         0       1./2
         0         0       1./L         0         0         0         0         0      -1./L         0      -1./2         0
         0         0         0         0         0         0         0         0         0         0         0         0
         0         0         0         0      -1./L         0         0         0         0         0       1./L         0
         0         0         0         0         0      -1./L         0         0         0         0         0       1./L
         0         0         0         0         0         0         0         0         0         0         0         0
         0      -1./L         0         0         0      -1./2         0       1./L         0         0         0         0
         0         0      -1./L         0       1./2         0         0         0       1./L         0         0         0]...
         *R;
end

end

%% cheaper 3x3 Cross product
function p = cross3(u,v)
    p = [u(2)*v(3); u(3)*v(1); u(1)*v(2)]-[u(3)*v(2); u(1)*v(3); u(2)*v(1)];
end
%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end
