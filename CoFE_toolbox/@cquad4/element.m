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

% nodal unit normals
j1=@(xi,eta) [obj.x1,obj.x2,obj.x3,obj.x4]*...
    [obj.dNdxi(1,xi,eta);
     obj.dNdxi(2,xi,eta);
     obj.dNdxi(3,xi,eta);
     obj.dNdxi(4,xi,eta)]; % tanget vector
 
j2=@(xi,eta) [obj.x1,obj.x2,obj.x3,obj.x4]*...
    [obj.dNdeta(1,xi,eta);
     obj.dNdeta(2,xi,eta);
     obj.dNdeta(3,xi,eta);
     obj.dNdeta(4,xi,eta)]; % tanget vector

obj.n1 = cross(j1(-1,-1),j2(-1,-1)); obj.n1 = obj.n1./norm(obj.n1);
obj.n2 = cross(j1( 1,-1),j2( 1,-1)); obj.n2 = obj.n2./norm(obj.n2); 
obj.n3 = cross(j1( 1, 1),j2( 1, 1)); obj.n3 = obj.n3./norm(obj.n3); 
obj.n4 = cross(j1(-1, 1),j2(-1, 1)); obj.n4 = obj.n4./norm(obj.n4);

% element y direction
v13 = obj.x3 - obj.x1;
v24 = obj.x4 - obj.x2;
ye = norm(v24)*v13+norm(v13)*v24;
obj.ye = ye./norm(ye);

% find property
pidH = [FEM.PSHELL.PID]==obj.PID;
assert(sum(pidH)==1,['There should be one and only one PROD with ID#',num2str(obj.PID),''])

% find MAT1
mat1H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID1;
assert(sum(mat1H)==1,['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID1),''])

% stress-strain matrix
obj.G = FEM.MAT1(mat1H).stress_strain_mat;
rho = FEM.MAT1(mat1H).RHO;

% thinkness - assumed constant for alpha testing
t = FEM.PSHELL(pidH).T;

%% stiffness matrix
ke = zeros(12);

% normal terms - ASTROS QUAD4 will need to integrate through thickness for bending
qn = gaussquad([2;2;1]);
for i = 1:size(qn.xi{1},1)
    for j = 1:size(qn.xi{1},2)
        for k = 1:size(qn.xi{1},3)
            B = [ones(2,12);zeros(1,12)] .* obj.B(qn.xi{1}(i,j,k),qn.xi{2}(i,j,k));
            ke = ke + ...
                B.'*obj.G*B * ...
                qn.w{1}(i,j,k) * qn.w{2}(i,j,k) * qn.w{3}(i,j,k) *  ...
                det(obj.Jacobian(qn.xi{1}(i,j,k),qn.xi{2}(i,j,k)));
        end
    end
end

% shear terms - using reduced order integration
qs = gaussquad([1;1;1]);
for i = 1:size(qs.xi{1},1)
    for j = 1:size(qs.xi{1},2)
        for k = 1:size(qs.xi{1},3)
            B = [zeros(2,12);ones(1,12)] .* obj.B(qs.xi{1}(i,j,k),qs.xi{2}(i,j,k));
            ke = ke + ...
                B.'*obj.G*B * ...
                qs.w{1}(i,j,k) * qs.w{2}(i,j,k) * qs.w{3}(i,j,k) *  ...
                det(obj.Jacobian(qs.xi{1}(i,j,k),qs.xi{2}(i,j,k)));
        end
    end
end
obj.ke = t/2*ke;

%% Mass Matrix
me = zeros(4);
qm = gaussquad([2;2]);
for i = 1:size(qm.xi{1},1)
    for j = 1:size(qm.xi{1},2)
        xi = qm.xi{1}(i,j);
        eta = qm.xi{2}(i,j);
        w1 = qm.w{1}(i,j);
        w2 = qm.w{2}(i,j);
        detJ = det(obj.Jacobian(xi,eta));
        for mi = 1:4
            for mj = 1:4
                me(mi,mj) = me(mi,mj) + obj.N(mi,xi,eta) * rho * obj.N(mj,xi,eta) * detJ * w1 * w2;
            end
        end
    end
end
obj.me = zeros(12);
obj.me([1,2,7,8],[1,2,7,8]) = t*me;

% keyboard
% % %% compare to bliq for planer
% kbliq = bliqmix( [obj.x1(1:2),obj.x2(1:2),obj.x3(1:2),obj.x4(1:2)]', t, obj.G );
% obj.ke([1,2,4,5,7,8,10,11],[1,2,4,5,7,8,10,11])
% kbliq
% (obj.ke([1,2,4,5,7,8,10,11],[1,2,4,5,7,8,10,11])-kbliq)./kbliq
