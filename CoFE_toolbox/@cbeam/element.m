% 'element' method for CBEAM
% Anthony Ricciardi
%
% Inputs:
% obj = [1x1] cbeam
% FEM = [1x1] fem
%
% Outputs
% obj = [1x1] cbeam - modified
%
function obj = element(obj,FEM)

% find GRIDs
h1 = find(FEM.gnum==obj.GA);
if size(h1,2)~=1; error(['There should be one and only one GRID with ID# ',num2str(obj.GA),'']); end
h2 = find(FEM.gnum==obj.GB);
if size(h2,2)~=1; error(['There should be one and only one GRID with ID# ',num2str(obj.GB),'']); end

% nodal locations
obj.x1 = [FEM.GRID(h1).X1;FEM.GRID(h1).X2;FEM.GRID(h1).X3];
obj.x2 = [FEM.GRID(h2).X1;FEM.GRID(h2).X2;FEM.GRID(h2).X3];

% global dof
obj.gdof = [FEM.gnum2gdof(:,h1);
            FEM.gnum2gdof(:,h2)];

% find property
pidH = find([FEM.PBEAM.PID]==obj.PID);
if size(pidH,2) > 1; error(['There should be one and only one PBEAM or PBEAML with ID# ',num2str(obj.PID),'']); end
if size(pidH,2) == 1
    obj_pbeam = FEM.PBEAM(pidH);
else
    pidH = find([FEM.PBEAML.PID]==obj.PID);
    if size(pidH,2)~=1; error(['There should be one and only one PBEAM or PBEAML with ID# ',num2str(obj.PID),'']); end
    obj_pbeam = FEM.PBEAML(pidH);
end

% find MAT1
mat1H = find([FEM.MAT1.MID]==obj_pbeam.MID);
if size(mat1H,2)~=1; error(['There should be one and only one MAT1 with ID# ',num2str(FEM.PROD(pidH).MID),'']); end
obj_mat1 = FEM.MAT1(mat1H);
[E,G,NU] = getEGNU(obj_mat1);

% element matrices
nuVec = [obj.X1;obj.X2;obj.X3];

if any([FEM.CASE.SOL] == 105)
    [obj.R,obj.ke,obj.me,obj.kdp,obj.kdvy,obj.kdvz,obj.kdmy2,obj.kdmz2,obj.kdmx] = legacy.cbeamMat(obj.x1,obj.x2,nuVec,E,G,obj_pbeam.A,obj_pbeam.I2,obj_pbeam.I1,obj_pbeam.J,obj_mat1.RHO,obj_pbeam.NSM,obj_pbeam.K1,obj_pbeam.K2);
else
    [obj.R,obj.ke,obj.me] = legacy.cbeamMat(obj.x1,obj.x2,nuVec,E,G,obj_pbeam.A,obj_pbeam.I2,obj_pbeam.I1,obj_pbeam.J,obj_mat1.RHO,obj_pbeam.NSM,obj_pbeam.K1,obj_pbeam.K2);
end

% force-stress matrix
StressC = [1/obj_pbeam.A, 0, 0, 0, obj_pbeam.C2/obj_pbeam.I2, -obj_pbeam.C1/obj_pbeam.I1];
StressD = [1/obj_pbeam.A, 0, 0, 0, obj_pbeam.D2/obj_pbeam.I2, -obj_pbeam.D1/obj_pbeam.I1];
StressE = [1/obj_pbeam.A, 0, 0, 0, obj_pbeam.E2/obj_pbeam.I2, -obj_pbeam.E1/obj_pbeam.I1];
StressF = [1/obj_pbeam.A, 0, 0, 0, obj_pbeam.F2/obj_pbeam.I2, -obj_pbeam.F1/obj_pbeam.I1];
obj.force_stress = [-StressC StressC;
    -StressD StressD;
    -StressE StressE;
    -StressF StressF];

% stress-strain matrix
obj.stress_strain = [1/E; -NU/E];
end