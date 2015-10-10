% Function returns the element matrices for CROD space truss element 
% in the global reference frame.
% Anthony Ricciardi 
%
% Inputs
% p1 = [3x1] coordinates (x1,y1,z1) for the first node
% p2 = [3x1] coordinates (x2,y2,z2) for the second node
% E = modulus of elasticity 
% G = shear modulus of elasticity 
% A = cross-sectional area 
% J = torsional constant
% rho = material density
% NSM = nonstructural mass per unit length
%
% Outputs
% R = [12 x 12] rotation matrix from element frame to global frame
% ke_g = [12 x 12] element stiffness matrix in the global frame
% me_g = [12 x 12] element mass matrix in the global frame
% kdp_g = [12 x 12] element differential stiffness matrix in the global frame
%
% % Components of differential stiffness matrix (all in global frame)
% % Not supported
%
function [R,ke_g,me_g,kdp_g] = crodMat(p1,p2,E,G,A,J,rho,NSM)

L = norm_cs(p2-p1); % norm(p2-p1) is not complex step friendly % sqrt( (p2(1)-p1(1)).^2 + (p2(2)-p1(2)).^2 + (p2(3)-p1(3)).^2 ); 

%% Direction Cosine Matrix
xVec = p2 - p1; xVec = xVec./norm_cs(xVec);
zVec = [0;0;1];
if sum(abs(xVec - zVec)) < .1 || sum(abs(xVec + zVec)) < .1
    zVec = [1;0;0];
end
yVec = cross3(zVec,xVec); yVec = yVec./norm_cs(yVec);
zVec = cross3(xVec,yVec); zVec = zVec./norm_cs(zVec);

Lambda = [xVec, yVec, zVec].';

R(10:12,10:12) = Lambda;
R(7:9,7:9) = Lambda;
R(4:6,4:6) = Lambda;
R(1:3,1:3) = Lambda;


%% Elastic Stiffness Matrix
kprime = zeros(12);
kprime(1,1) = E.*A./L;
kprime(7,7) = E.*A./L;
kprime(1,7) =-E.*A./L;
kprime(7,1) =-E.*A./L;
kprime(4,4) = G.*J./L;
kprime(10,10) = G.*J./L;
kprime(4,10) =-G.*J./L;
kprime(10,4) =-G.*J./L;
ke_g = R.'*kprime*R;

%% Mass Matrix
if nargout > 2
    % Nastran 
    mprime = [...
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

% Consistant (answer very close to Grandi and Venkayya)
%     mprime = [...
%          2         0         0         0         0         0         1         0         0         0         0         0
%          0         3         0         0         0         0         0         0         0         0         0         0
%          0         0         3         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0
%          1         0         0         0         0         0         2         0         0         0         0         0
%          0         0         0         0         0         0         0         3         0         0         0         0
%          0         0         0         0         0         0         0         0         3         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0
%          0         0         0         0         0         0         0         0         0         0         0         0];

    me_g = R.'*(  (1./6.*(rho.*A+NSM).*L).*mprime ) *R;
    
%% Differential Stiffness Matrix for P = 1
    if nargout > 3
        kdp_g_prime = (1/L) * [
            0     0     0     0     0     0     0     0     0     0     0     0
            0     1     0     0     0     0     0    -1     0     0     0     0
            0     0     1     0     0     0     0     0    -1     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0
            0    -1     0     0     0     0     0     1     0     0     0     0
            0     0    -1     0     0     0     0     0     1     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0
            0     0     0     0     0     0     0     0     0     0     0     0];
        kdp_g = R.'*kdp_g_prime *R;
%         warning('The differential stiffness may be inaccurate if there is torsional flexibility in truss elements')
    end
end
end

%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end
%% cheaper 3x3 Cross product
function p = cross3(u,v)
    p = [u(2)*v(3); u(3)*v(1); u(1)*v(2)]-[u(3)*v(2); u(1)*v(3); u(2)*v(1)];
end