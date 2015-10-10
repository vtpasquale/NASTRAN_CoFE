function [obj,obj_prime] = recover(obj,gnum2gdof,globalDef,obj_prime,globalDef_prime)

% analysis results
elDef = globalDef([gnum2gdof(1:2,obj.G1);gnum2gdof(1:2,obj.G2);gnum2gdof(1:2,obj.G3);gnum2gdof(1:2,obj.G4)]) ;
obj.stress = bliqstr( elDef, [obj.x1(1:2),obj.x2(1:2),obj.x3(1:2),obj.x4(1:2)]', obj.G );

% Design Derivatives
if nargin > 3
%     elDef_prime = globalDef_prime([gnum2gdof(:,obj.G1);gnum2gdof(:,obj.G2)]);
%     obj_prime.force = (obj.R*obj.ke)*elDef_prime + ...
%         (d(obj_prime.R)*obj.ke + obj.R*d(obj_prime.ke))*elDef;
%     obj_prime.stress = d(obj_prime.force_stress)*obj.force + ...
%         obj.force_stress*obj_prime.force;
end

end

%%
function [sigma,centroid,dStress] = bliqstr( d, xy, EE, StressPoints )
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
[npe,ndf]=size(xy);
B = zeros(3,npe*ndf);
if nargin<4, StressPoints=[]; end
if isempty(StressPoints)
    StressPoints  = [-1  1 1 -1 0
        -1 -1 1  1 0];
elseif size(StressPoints,1)~=2 & size(StressPoints,2)==2
    StressPoints=StressPoints';
end
npt = size(StressPoints,2);
sigma = zeros(3,npt);
if nargout>=3, dStress = zeros(3,2,npt); end
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
    sigma(:,j) = EE*B*d;
    
    % Derivatives of stress w.r.t. x and y
    if nargout>2
        Jinv = inv(J);
        DNxi  = [0  0  0  0
            1 -1  1 -1]/4;
        DNeta = [1 -1  1 -1
            0  0  0  0]/4;
        Bxi  = expandB( Jinv * (DNxi  - DNxi*xy*Jinv*DN) );
        Beta = expandB( Jinv * (DNeta - DNeta*xy*Jinv*DN) );
        dStress(:,:,j) = EE*[(Bxi*Jinv(1,1) + Beta*Jinv(1,2) )*d, ...
            (Bxi*Jinv(2,1) + Beta*Jinv(2,2) )*d];
    end
end
if nargout > 1
    centroid = [mean(xy(:,1)) mean(xy(:,2))];
end



    function B = expandB( Nxy )
        B(1,[1 3 5 7]) = Nxy(1,:);
        B(2,[2 4 6 8]) = Nxy(2,:);
        B(3,[1 3 5 7]) = Nxy(2,:);
        B(3,[2 4 6 8]) = Nxy(1,:);
    end

end