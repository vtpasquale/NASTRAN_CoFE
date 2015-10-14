% define node locations
function obj = element(obj,FEM)

% find GRIDs
h1 = find(FEM.gnum==obj.G1);
assert(size(h1,2)==1,['There should be one and only one GRID with ID#',num2str(obj.G1),''])
h2 = find(FEM.gnum==obj.G2);
assert(size(h2,2)==1,['There should be one and only one GRID with ID#',num2str(obj.G2),''])
h3 = find(FEM.gnum==obj.G3);
assert(size(h3,2)==1,['There should be one and only one GRID with ID#',num2str(obj.G3),''])
h4 = find(FEM.gnum==obj.G4);
assert(size(h4,2)==1,['There should be one and only one GRID with ID#',num2str(obj.G4),''])

% global dof
obj.gdof = [FEM.gnum2gdof(1:3,h1);
            FEM.gnum2gdof(1:3,h2);
            FEM.gnum2gdof(1:3,h3);
            FEM.gnum2gdof(1:3,h4)];

% nodal locations
obj.x1 = [FEM.GRID(h1).X1;FEM.GRID(h1).X2;FEM.GRID(h1).X3];
obj.x2 = [FEM.GRID(h2).X1;FEM.GRID(h2).X2;FEM.GRID(h2).X3];
obj.x3 = [FEM.GRID(h3).X1;FEM.GRID(h3).X2;FEM.GRID(h3).X3];
obj.x4 = [FEM.GRID(h4).X1;FEM.GRID(h4).X2;FEM.GRID(h4).X3];

% G1-G4 must be in located in a plane parallel to the basic coordinate system x-y plane.
if any(obj.x1(3)~=[obj.x2(3) obj.x3(3) obj.x4(3)]) || ...
        any(obj.x2(3)~=[obj.x3(3) obj.x4(3)])  || obj.x3(3) ~= obj.x4(3)
    error('G1-G4 must be in located in a plane parallel to the basic coordinate system x-y plane.');
end

% find property
pidH = [FEM.PSHELL.PID]==obj.PID;
assert(sum(pidH)==1,['There should be one and only one PROD with ID#',num2str(obj.PID),''])

% find MAT1
mat1H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID1;
assert(sum(mat1H)==1,['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID1),''])

% stress-strain matrix
obj.G = FEM.MAT1(mat1H).stress_strain_mat;
% rho = FEM.MAT1(mat1H).RHO;

% thinkness - assumed constant for alpha testing
t = FEM.PSHELL(pidH).T;

%% stiffness matrix
kbliq = bliqmix( [obj.x1(1:2),obj.x2(1:2),obj.x3(1:2),obj.x4(1:2)]', t, obj.G );

obj.ke = zeros(12);
obj.ke([1,2,4,5,7,8,10,11],[1,2,4,5,7,8,10,11])  = kbliq;
obj.me = zeros(12);
end

%%
function k = bliqmix( xy, thick, EE )
% bliqmix.m - Generates Blinear Isoparametric Quadrilateral
%             element stiffness matrix by mixed order integration.
%
% Written by: Robert A. Canfield
% Created:    27 Jun 01
% Modified:   14 Aug 01
%
%--INPUT
%
%  xy....... nodal coordinates in each row,
%            x in column 1, y in column 2
%  thick.... membrane thickness
%  EE....... Elastic constant matrix (3x3)
%
%--OUTPUT
%
%  k........ BLIQ element stiffness

%
%--Local variables
%
%  n........ number of element degrees of freedom
%  B........ strain-displacement matrix
%  xi,eta... Current Gauss point
%  DN....... Derivatives of shape functions wrt to natural coordinates
%  Nxy...... Derivatives of shape functions wrt to Cartesian coordinates
%  J........ Jacobian matrix
%  GaussPoints... Natural coordinates of Gauss points
%
%--BEGIN
%
%  Initialize variables
%
[npe,ndf]=size(xy);
n = npe*ndf;
k = zeros(n,n);
B = zeros(3,n);
GaussPoints = [-1 1]/sqrt(3);
%
%  Double loop for Full order (2 by 2) Gauss quadrature of normal strain terms
%
for xi=GaussPoints;
   for eta=GaussPoints;
      DN = 1/4 * [
         -(1-eta), (1-eta), (1+eta), -(1+eta)
         -(1-xi), -(1+xi),  (1+xi),   (1-xi) ];
      J = DN*xy;
      Nxy = J \ DN;
      B(1,[1 3 5 7]) = Nxy(1,:);
      B(2,[2 4 6 8]) = Nxy(2,:);
      k = k + B'*(EE*B*(thick*abs(det(J))));
   end
end
%
%  Reduced order (1 by 1) integration for shear terms
%
xi = 0;
eta = 0;
weight = 2;
      DN = 1/4 * [
         -(1-eta), (1-eta), (1+eta), -(1+eta)
         -(1-xi), -(1+xi),  (1+xi),   (1-xi) ];
      J = DN*xy;
      Nxy = J \ DN;
      B(3,[1 3 5 7]) = Nxy(2,:);
      B(3,[2 4 6 8]) = Nxy(1,:);
      kshear = B(3,:)'*(EE(3,3)*B(3,:)*(thick*abs(det(J))*weight^2));
k = k + kshear;
end