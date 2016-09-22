% define node locations
function obj = element(obj,FEM)

% find GRIDs
h1 = find(FEM.gnum==obj.G1);
if size(h1,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.G1),'']); end
h2 = find(FEM.gnum==obj.G2);
if size(h2,2)~=1,error(['There should be one and only one GRID with ID#',num2str(obj.G2),'']); end
h3 = find(FEM.gnum==obj.G3);
if size(h3,2)~=1,error(['There should be one and only one GRID with ID#',num2str(obj.G3),'']); end
h4 = find(FEM.gnum==obj.G4);
if size(h4,2)~=1,error(['There should be one and only one GRID with ID#',num2str(obj.G4),'']); end

% global dof
obj.gdof = [FEM.gnum2gdof(1:6,h1);
            FEM.gnum2gdof(1:6,h2);
            FEM.gnum2gdof(1:6,h3);
            FEM.gnum2gdof(1:6,h4)];

% nodal locations
obj.x1 = [FEM.GRID(h1).X1;FEM.GRID(h1).X2;FEM.GRID(h1).X3];
obj.x2 = [FEM.GRID(h2).X1;FEM.GRID(h2).X2;FEM.GRID(h2).X3];
obj.x3 = [FEM.GRID(h3).X1;FEM.GRID(h3).X2;FEM.GRID(h3).X3];
obj.x4 = [FEM.GRID(h4).X1;FEM.GRID(h4).X2;FEM.GRID(h4).X3];

% element coordinate system
x0 = .25*(obj.x1 + obj.x2 + obj.x3 + obj.x4);
xE = .5*(obj.x2 + obj.x3) - x0; xE = xE./norm_cs(xE);
zE = cross3(obj.x2-x0,obj.x3-x0); zE = zE./norm_cs(zE);
yE = cross3(zE,xE); yE = yE./norm_cs(yE);
TEG = [xE,yE,zE].';

% node positions in element coordinate system
XE = TEG *([obj.x1,obj.x2,obj.x3,obj.x4]-[x0,x0,x0,x0]);
obj.XE = XE;

% nodal unit normals
j1=@(xi,eta) .25*XE*[      -(1-eta),       (1-eta),       (1+eta),      -(1+eta)].';
j2=@(xi,eta) .25*XE*[(1-xi)*-1     ,(1+xi)*-1     ,(1+xi)        ,(1-xi)        ].';

obj.n1 = cross3(j1(-1,-1),j2(-1,-1)); obj.n1 = obj.n1./norm_cs(obj.n1);
obj.n2 = cross3(j1( 1,-1),j2( 1,-1)); obj.n2 = obj.n2./norm_cs(obj.n2); 
obj.n3 = cross3(j1( 1, 1),j2( 1, 1)); obj.n3 = obj.n3./norm_cs(obj.n3); 
obj.n4 = cross3(j1(-1, 1),j2(-1, 1)); obj.n4 = obj.n4./norm_cs(obj.n4);

% find property
pidH = [FEM.PSHELL.PID]==obj.PID;
if sum(pidH)~=1; error(['There should be one and only one PROD with ID#',num2str(obj.PID),'']); end

% materials
if FEM.PSHELL(pidH).MID1 ~= -999;
    mat1H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID1;
    if sum(mat1H)~=1; error(['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID1),'']); end
    G1 = FEM.MAT1(mat1H).stress_strain_mat;
else
    G1 = zeros(3);
end

if FEM.PSHELL(pidH).MID2 == FEM.PSHELL(pidH).MID1
    G2 = G1;
elseif FEM.PSHELL(pidH).MID2 ~= -999;
    mat2H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID2;
    if sum(mat2H)~=1; error(['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID2),'']); end
    G2 = FEM.MAT1(mat2H).stress_strain_mat;
else
    G2 = zeros(3);
end

if FEM.PSHELL(pidH).MID2 == -999;
    G3 = G2; % = zeros(3); % no transverse shear stiffness without bending stiffness
elseif FEM.PSHELL(pidH).MID3 == FEM.PSHELL(pidH).MID1
    G3 = G1;
elseif FEM.PSHELL(pidH).MID3 == FEM.PSHELL(pidH).MID2
    G3 = G2;
elseif FEM.PSHELL(pidH).MID3 ~= -999;
    mat3H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID3;
    if sum(mat3H)~=1; error(['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID3),'']); end
    G3 = FEM.MAT1(mat3H).stress_strain_mat;
else
    G3 = G2; % Kirchhoff or classical plate theory (no shear flexibility) is not supported, so, if not defined, shear material properties based on bending material properties
end

% shell stress-strain matrix (bending relationship is scaled by t^3/12 at integration point)
obj.G= [G1          ,zeros(3,3)                     , zeros(3,2) 
        zeros(3,3)  ,FEM.PSHELL(pidH).n12I_Tpwr3*G2 , zeros(3,2)
        zeros(2,3)  ,zeros(2,3)                     , FEM.PSHELL(pidH).TS_T*G3(3,3)*eye(2)];

% material density
obj.rho = FEM.MAT1(mat1H).RHO;

% nonstructural mass
obj.NSM = FEM.PSHELL(pidH).NSM;

% thinknesses
if obj.TFLAG  == 0
    obj.t = [obj.T1,obj.T2,obj.T3,obj.T4];
else
    if FEM.PSHELL(pidH).T == -999
        error(['The PSHELL T property is blank for PSHELL EID=',FEM.PSHELL(pidH).EID,'; the PSHELL T property is referenced because TFLAG = 1 for CQUAD4 EID=',obj.EID,'.']);
    end
    obj.t = FEM.PSHELL(pidH).T*[obj.T1,obj.T2,obj.T3,obj.T4];
end

%% Coordinate transformation at nodes
obj.A = zeros(3,3,4);
for n =1:4
    switch n
        case 1
            z_n = obj.n1;
        case 2
            z_n = obj.n2;
        case 3
            z_n = obj.n3;
        case 4
            z_n = obj.n4;
    end
    x_n = cross3([0 1 0],z_n)./norm_cs(cross3([0 1 0],z_n));
    y_n = cross3(z_n,x_n);
    TNIE= [x_n.';y_n.';z_n.'];
    obj.A(1:3,1:3,n) = TNIE.'*[0 1 0; -1 0 0; 0 0 1]*TNIE;
end

%% element integration
ke = zeros(24);
me = zeros(24);

% Mass matrix indicies
mi1 = 1:6:24;
mi2 = 2:6:24;
mi3 = 3:6:24;

% Loop through Gauss points
XI = 1/sqrt(3)*[-1 -1; 1 1];
ETA = 1/sqrt(3)*[-1 1; -1 1];
for i = 1:2
    for j = 1:2
        xi = XI(i,j);
        eta = ETA(i,j);
        
        [kn,~,mp] = ele_p(obj,xi,eta,1);
        ke = ke + kn;
        
        me(mi1,mi1) = me(mi1,mi1) + mp;
        me(mi2,mi2) = me(mi2,mi2) + mp;
        me(mi3,mi3) = me(mi3,mi3) + mp;
    end
end

% if centerpoint recovery - save GBCT, GBCB
[~,ks,~,CBB,CBT,obj.tc] = ele_p(obj,0,0,2);
ke = ke + 4*ks;

% if grid point recovery - save N#BT,N#BB
[~,~,~,N1BB,N1BT] = ele_p(obj,-1,-1,0);
[~,~,~,N2BB,N2BT] = ele_p(obj,1,-1,0);
[~,~,~,N3BB,N3BT] = ele_p(obj,1,1,0);
[~,~,~,N4BB,N4BT] = ele_p(obj,-1,1,0);

%% single point Gauss quadrature
% [kn,ks,mp] = ele_p(obj,0,0);
% me(mi1,mi1) = me(mi1,mi1) + 4*mp;
% me(mi2,mi2) = me(mi2,mi2) + 4*mp;
% me(mi3,mi3) = me(mi3,mi3) + 4*mp;
% ke = ke + 4*kn + 4*ks;

%% transform to global coordinate system and save
REG(22:24,22:24)=TEG;REG(19:21,19:21)=TEG;REG(16:18,16:18)=TEG;REG(13:15,13:15)=TEG;
REG(10:12,10:12)=TEG;REG(7:9,7:9)=TEG;REG(4:6,4:6)=TEG;REG(1:3,1:3)=TEG;
RGE = REG.';

obj.ke =  sparse(RGE*ke*REG);
obj.me =  sparse(RGE*me*REG);


% strain-displacement matricies at centerpoint
obj.CBB = sparse(CBB*REG);
obj.CBT = sparse(CBT*REG);

% strain-displacement matricies at nodes
obj.N1BB=sparse(N1BB*REG);
obj.N1BT=sparse(N1BT*REG);
obj.N2BB=sparse(N2BB*REG);
obj.N2BT=sparse(N2BT*REG);
obj.N3BB=sparse(N3BB*REG);
obj.N3BT=sparse(N3BT*REG);
obj.N4BB=sparse(N4BB*REG);
obj.N4BT=sparse(N4BT*REG);

end

%% cheaper 3x3 Cross product
function p = cross3(u,v)
    p = [u(2)*v(3); u(3)*v(1); u(1)*v(2)]-[u(3)*v(2); u(1)*v(3); u(2)*v(1)];
end
%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end