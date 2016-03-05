function obj = element(obj,FEM)
% find matching GRID
h = find(FEM.gnum==obj.G1);
if size(h,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.G1),'']); end

% nodal locations
obj.x1 = [FEM.GRID(h).X1;FEM.GRID(h).X2;FEM.GRID(h).X3];

% global dof
obj.gdof = FEM.gnum2gdof(obj.C1,obj.G1==FEM.gnum);

% plot dof
obj.gdof_plot = FEM.gnum2gdof(1:3,obj.G1==FEM.gnum);

% find property
pidH = [FEM.PMASS.PID1]==obj.PID;
if sum(pidH)~=1; error(['There should be one and only one PROD with ID#',num2str(obj.PID),'']); end

% element matricies
obj.ke = 0;
obj.me = FEM.PMASS(pidH).M1;
