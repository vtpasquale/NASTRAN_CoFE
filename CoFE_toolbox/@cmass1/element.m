function obj = element(obj,FEM)
% find matching GRID
h = FEM.gnum==obj.G1;
assert(sum(h)==1,['There should be one and only one GRID with ID#',num2str(obj.G1),''])

% nodal locations
obj.x1 = [FEM.GRID(h).X1;FEM.GRID(h).X2;FEM.GRID(h).X3];

% global dof
obj.gdof = FEM.gnum2gdof(obj.C1,obj.G1==FEM.gnum);

% find property
pidH = [FEM.PMASS.PID1]==obj.PID;
assert(sum(pidH)==1,['There should be one and only one PMASS with ID#',num2str(obj.PID),''])

% element matricies
obj.ke = 0;
obj.me = FEM.PMASS(pidH).M1;
