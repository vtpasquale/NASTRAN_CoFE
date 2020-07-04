function [T_e0,k_e,m_e,volume,mass] = getBeamElementMatrices(p1,p2,nu_0,E,G,A,Iy,Iz,J,rho,nsm,k1,k2,coupledMassFlag)
% Returns the element matrices for a prismatic BEAM/BAR element in 3D space.
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
% volume [double] element volume
% mass [double] element mass
            
% Anthony Ricciardi

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

% Volume and mass
volume = L*A;
mass = volume*rho;


end