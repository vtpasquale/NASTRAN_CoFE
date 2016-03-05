function obj = element(obj,FEM)
% find GRIDs
h1 = find(FEM.gnum==obj.G1);
if size(h1,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.G1),'']); end
h2 = find(FEM.gnum==obj.G2);
if size(h2,2)~=1,error(['There should be one and only one GRID with ID#',num2str(obj.G2),'']); end

% node locations
obj.x1 = [FEM.GRID(h1).X1;FEM.GRID(h1).X2;FEM.GRID(h1).X3];
obj.x2 = [FEM.GRID(h2).X1;FEM.GRID(h2).X2;FEM.GRID(h2).X3];

% global dof
obj.gdof = [FEM.gnum2gdof(obj.C1,h1);
            FEM.gnum2gdof(obj.C2,h2)];
% plot dof
obj.gdof_plot = [FEM.gnum2gdof(1:3,h1),FEM.gnum2gdof(1:3,h2)];

% element matricies
obj.ke = [obj.K -obj.K; -obj.K obj.K];
obj.me = 0;
