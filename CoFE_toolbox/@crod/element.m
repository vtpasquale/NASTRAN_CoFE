% 'element' method for CROD
% Anthony Ricciardi
%
% Inputs:
% obj = [1x1] crod
% FEM = [1x1] fem
%
% Outputs
% obj = [1x1] crod - modified
%
function obj = element(obj,FEM)

% find GRIDs
h1 = find(FEM.gnum==obj.G1);
if size(h1,2)~=1; error(['There should be one and only one GRID with ID# ',num2str(obj.G1),'']); end
h2 = find(FEM.gnum==obj.G2);
if size(h2,2)~=1; error(['There should be one and only one GRID with ID# ',num2str(obj.G2),'']); end

% nodal locations
obj.x1 = [FEM.GRID(h1).X1;FEM.GRID(h1).X2;FEM.GRID(h1).X3];
obj.x2 = [FEM.GRID(h2).X1;FEM.GRID(h2).X2;FEM.GRID(h2).X3];

% global dof
obj.gdof = [FEM.gnum2gdof(:,h1);
            FEM.gnum2gdof(:,h2)];

% find property
pidH = find([FEM.PROD.PID]==obj.PID);
if size(pidH,2)~=1; error(['There should be one and only one PROD with ID# ',num2str(obj.PID),'']); end

% find MAT1
mat1H = find([FEM.MAT1.MID]==FEM.PROD(pidH).MID);
if size(mat1H,2)~=1; error(['There should be one and only one MAT1 with ID# ',num2str(FEM.PROD(pidH).MID),'']); end
[E,G,NU] = getEGNU(FEM.MAT1(mat1H));

% element matricies
if any([FEM.CASE.SOL] == 105)
    [obj.R,obj.ke,obj.me,obj.kd_unit_p] = legacy.crodMat(obj.x1,obj.x2,E,G,FEM.PROD(pidH).A,FEM.PROD(pidH).J,FEM.MAT1(mat1H).RHO,FEM.PROD(pidH).NSM);
else
    [obj.R,obj.ke,obj.me] = legacy.crodMat(obj.x1,obj.x2,E,G,FEM.PROD(pidH).A,FEM.PROD(pidH).J,FEM.MAT1(mat1H).RHO,FEM.PROD(pidH).NSM);
end

% force-stress matrix
obj.force_stress = 1./FEM.PROD(pidH).A;

% stress-strain matrix
obj.stress_strain = [1/E; -NU/E];

end