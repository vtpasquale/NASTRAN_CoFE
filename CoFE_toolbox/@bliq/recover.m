function [obj,obj_prime] = recover(obj,FEM,obj_prime,FEM_prime)

% analysis results
u_ee = FEM.u(obj.gdof,:);
u_e = u_ee([1,2,4,5,7,8,10,11],:);

nm = size(u_e,2);
FEMCASE=FEM.CASE; % speeds up execution


XN = [obj.x1(1:2),obj.x2(1:2),obj.x3(1:2),obj.x4(1:2)].';
XC = sum(XN)./4;

if nargin < 3
    % element kinetic energy
    if FEMCASE.EKE && FEMCASE.SOL == 103
        obj.eke= (pi*FEM.fHz).*diag(u_ee.'*obj.me*u_ee);
    end
    
    % element strain energy
    if FEMCASE.ESE
        obj.ese=.5*diag(u_ee.'*obj.ke*u_ee);
    end
    
    if FEMCASE.STRESS || FEMCASE.STRAIN
        
        % stress and strain
        [sigma,strain] = bliqstr(u_e, XN, obj.G, [XC;XN]);
        
        % [6 x nm x 5], [s11 s22 s33 s23 s13 s12]
        obj.voigtStress = zeros(6,nm,5);
        obj.voigtStress([1,6,5],:,:) = sigma;
        
        obj.voigtStrain = zeros(6,nm,5);
        obj.voigtStrain([1,6,5],:,:) = strain;
    end
else
    %% Design Derivatives
    u_ee_prime = FEM_prime.u(obj.gdof,:);
    u_e_prime = u_ee_prime([1,2,4,5,7,8,10,11],:);
    
    % element kinetic energy
    if FEMCASE.EKE && FEMCASE.SOL == 103
        obj_prime.eke= pi*FEM_prime.fHz.*diag(u_ee.'*obj.me*u_ee) + ...
            pi*FEM.fHz.*diag(u_ee.'*d(obj_prime.me)*u_ee + 2*u_ee.'*obj.me*u_ee_prime);
    end
    
    % element strain energy
    if FEMCASE.ESE
        obj_prime.ese= .5*diag(u_ee.'*d(obj_prime.ke)*u_ee + 2*u_ee.'*obj.ke*u_ee_prime);
    end
    
    if FEMCASE.STRESS || FEMCASE.STRAIN
        obj_prime.voigtStrain_fromAnalysis = obj.voigtStrain;
        obj_prime.voigtStress_fromAnalysis = obj.voigtStress;
        
        % stress and strain
        XN_prime = [obj_prime.x1(1:2),obj_prime.x2(1:2),obj_prime.x3(1:2),obj_prime.x4(1:2)].';
        XC_prime = sum(XN_prime)./4;
        
        % use complex step form
        [sigma,strain] = bliqstr(u_e+1i*eps*u_e_prime, XN_prime, obj_prime.G, [XC_prime;XN_prime]);
        
        % [6 x nm x 5], [s11 s22 s33 s23 s13 s12]
        obj_prime.voigtStress = zeros(6,nm,5);
        obj_prime.voigtStress([1,6,5],:,:) = d(sigma);
        
        obj_prime.voigtStrain = zeros(6,nm,5);
        obj_prime.voigtStrain([1,6,5],:,:) = d(strain);
    end
    
end

end

%%
function [sigma,strain] = bliqstr( d, xy, EE, StressPoints )
% bliqstr.m - Bilinear Isoparametric Quadrilateral element stress.
%
% Written by: Robert A. Canfield
% Created:    2 Jul 01
% Modified:  20 Nov 04
%
%--INPUT
%
%  d.............. nodal displacements
%  xy............. nodal coordinates in each row,
%                  x in column 1, y in column 2
%  EE............. Elastic constant matrix (3x3)
%  StressPoints... Natural coordinates of stress recovery points
%
%--OUTPUT
%
%  sigma...... BLIQ element stress components at StressPoints
%  centroid... BLIQ element's centroidal coordinates
%  dStress.... Derivates of stress with respect to x and y coordinates
%              array of size 3 stress components by 2 spatial coordinates by npt
%              Defaults to corners and center

%
%--Local variables
%
%  n........ number of element degrees of freedom
%  B........ strain-displacement matrix
%  xi,eta... Current stress recovery point's natural coordinates
%  npt...... Number of stress recovery points
%
%--BEGIN
%
%  Initialize variables
%
nm = size(d,2);
if nargin<4, StressPoints=[]; end
if isempty(StressPoints)
    StressPoints  = [-1  1 1 -1 0
        -1 -1 1  1 0];
elseif size(StressPoints,1)~=2 & size(StressPoints,2)==2
    StressPoints=StressPoints';
end
npt = size(StressPoints,2);
sigma = zeros(3,nm,npt);
strain = zeros(3,nm,npt);

%
%  Loop for each stress recovery point
%
for j=1:npt;
    xi  = StressPoints(1,j);
    eta = StressPoints(2,j);
    DN = 1/4 * [
        -(1-eta), (1-eta), (1+eta), -(1+eta)
        -(1-xi), -(1+xi),  (1+xi),   (1-xi) ];
    J = DN*xy;
    B = expandB( J \ DN );
    strain(:,:,j) = B*d;
    sigma(:,:,j) = EE*B*d;
    
end

    function B = expandB( Nxy )
        B(1,[1 3 5 7]) = Nxy(1,:);
        B(2,[2 4 6 8]) = Nxy(2,:);
        B(3,[1 3 5 7]) = Nxy(2,:);
        B(3,[2 4 6 8]) = Nxy(1,:);
    end

end