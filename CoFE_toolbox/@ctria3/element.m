% define node locations
function obj = element(obj,FEM)

% find GRIDs
h1 = find(FEM.gnum==obj.G1);
if size(h1,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.G1),'']); end
h2 = find(FEM.gnum==obj.G2);
if size(h2,2)~=1,error(['There should be one and only one GRID with ID#',num2str(obj.G2),'']); end
h3 = find(FEM.gnum==obj.G3);
if size(h3,2)~=1,error(['There should be one and only one GRID with ID#',num2str(obj.G3),'']); end

% global dof
obj.gdof = [FEM.gnum2gdof(1:6,h1);
            FEM.gnum2gdof(1:6,h2);
            FEM.gnum2gdof(1:6,h3)];

% nodal locations
obj.x1 = [FEM.GRID(h1).X1;FEM.GRID(h1).X2;FEM.GRID(h1).X3];
obj.x2 = [FEM.GRID(h2).X1;FEM.GRID(h2).X2;FEM.GRID(h2).X3];
obj.x3 = [FEM.GRID(h3).X1;FEM.GRID(h3).X2;FEM.GRID(h3).X3];
obj.x4 = obj.x3; % hack for plotting

% elemeobjnt coordinate system
x0 = obj.x1;
xE = obj.x2 - x0; xE = xE./norm_cs(xE);
zE = cross3(xE, obj.x3 - x0); zE = zE./norm_cs(zE);
yE = cross3(zE, xE); yE = yE./norm_cs(yE);
TEG = [xE,yE,zE].';

% node positions in element coordinate system
obj.XE = TEG*([obj.x1, obj.x2, obj.x3] - [x0, x0, x0]);

% nodal unit normals
obj.n1 = zE;
obj.n2 = zE; 
obj.n3 = zE;

% find property
pidH = [FEM.PSHELL.PID]==obj.PID;
if sum(pidH)~=1; error(['There should be one and only one PROD with ID#',num2str(obj.PID),'']); end

% materials
if FEM.PSHELL(pidH).MID1 ~= -999
    mat1H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID1;
    if sum(mat1H)~=1; error(['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID1),'']); end
    G1 = FEM.MAT1(mat1H).stress_strain_mat;
else
    G1 = zeros(3);
end

if FEM.PSHELL(pidH).MID2 == FEM.PSHELL(pidH).MID1
    G2 = G1;
elseif FEM.PSHELL(pidH).MID2 ~= -999
    mat2H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID2;
    if sum(mat2H)~=1; error(['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID2),'']); end
    G2 = FEM.MAT1(mat2H).stress_strain_mat;
else
    G2 = zeros(3);
end

if FEM.PSHELL(pidH).MID2 == -999
    G3 = G2; % = zeros(3); % no transverse shear stiffness without bending stiffness
elseif FEM.PSHELL(pidH).MID3 == FEM.PSHELL(pidH).MID1
    G3 = G1;
elseif FEM.PSHELL(pidH).MID3 == FEM.PSHELL(pidH).MID2
    G3 = G2;
elseif FEM.PSHELL(pidH).MID3 ~= -999
    mat3H = [FEM.MAT1.MID]==FEM.PSHELL(pidH).MID3;
    if sum(mat3H)~=1; error(['There should be one and only one MAT1 with ID#',num2str(FEM.PSHELL(pidH).MID3),'']); end
    G3 = FEM.MAT1(mat3H).stress_strain_mat;
else
    G3 = G2; % Kirchhoff or classical plate theory (no shear flexibility) is not supported, so, if not defined, shear material properties based on bending material properties
end

% shell stress-strain matrix (bending relationship is scaled by t^3/12 at integration point)
obj.G = [G1         ,zeros(3,3)                     , zeros(3,2) 
        zeros(3,3)  ,FEM.PSHELL(pidH).n12I_Tpwr3*G2 , zeros(3,2)
        zeros(2,3)  ,zeros(2,3)                     , FEM.PSHELL(pidH).TS_T*G3(3,3)*eye(2)];

% material density
obj.rho = FEM.MAT1(mat1H).RHO;

% nonstructural mass
obj.NSM = FEM.PSHELL(pidH).NSM;

% thicknesses
if obj.TFLAG  == 0
    obj.t = [obj.T1,obj.T2,obj.T3];
else
    if FEM.PSHELL(pidH).T == -999
        error(['The PSHELL T property is blank for PSHELL EID=',FEM.PSHELL(pidH).EID,'; the PSHELL T property is referenced because TFLAG = 1 for CQUAD4 EID=',obj.EID,'.']);
    end
    obj.t = FEM.PSHELL(pidH).T*[obj.T1,obj.T2,obj.T3];
end

%% element integration
ke = zeros(18);
me = zeros(18);

% Mass matrix indicies
mi1 = 1:6:18;
mi2 = 2:6:18;
mi3 = 3:6:18;


%% Three point Gauss quadrature for bending
% XI  = [2/3 1/6 1/6];
% ETA = [1/6 1/6 2/3];
% wt = 1/3;
% for i = 1:3
%     xi = XI(i);
%     eta = ETA(i);
%     
%     [kn,~,mp] = ele_p(obj,xi,eta,1);
%     ke = ke + wt*kn;
%     
%     me(mi1,mi1) = me(mi1,mi1) + wt*mp;
%     me(mi2,mi2) = me(mi2,mi2) + wt*mp;
%     me(mi3,mi3) = me(mi3,mi3) + wt*mp;
% end

% 2.01389E-4
% keyboard
% diagMe = sum(me,2).';
% sum(diagMe(1:6:end))
% ans/2.01389E-4

[kn,~,mp] = ele_p(obj,1/3,1/3,1);
ke = ke + kn;
me(mi1,mi1) = me(mi1,mi1) + mp;
me(mi2,mi2) = me(mi2,mi2) + mp;
me(mi3,mi3) = me(mi3,mi3) + mp;

%% single point Gauss quadrature for shear
% if centerpoint recovery - save GBCT, GBCB
[~,ks,~,CBB,CBT,obj.tc] = ele_p(obj,1/3,1/3,2);
ke = ke + ks;

% if grid point recovery - save N#BT,N#BB
[~,~,~,N1BB,N1BT] = ele_p(obj,1,0,0);
[~,~,~,N2BB,N2BT] = ele_p(obj,0,1,0);
[~,~,~,N3BB,N3BT] = ele_p(obj,0,0,0);

%% transform to global coordinate system and save
REG(16:18,16:18)=TEG;REG(13:15,13:15)=TEG;
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

end

%% cheaper 3x3 Cross product
function p = cross3(u,v)
    p = [u(2)*v(3); u(3)*v(1); u(1)*v(2)]-[u(3)*v(2); u(1)*v(3); u(2)*v(1)];
end
%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end