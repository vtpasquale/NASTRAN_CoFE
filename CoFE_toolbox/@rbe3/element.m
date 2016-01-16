function obj = element(obj,FEM)

%% dependent degrees of freedom (m set) 
% numbers and locations
hm = find(FEM.gnum==obj.REFGRID);
if size(hm,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.REFGRID),'']); end
obj.xm = [FEM.GRID(hm).X1;FEM.GRID(hm).X2;FEM.GRID(hm).X3];

% global dof
ldofm = str2num(num2str(obj.REFC)');
obj.gdofm = FEM.gnum2gdof(ldofm,hm)';

% plot indices
obj.gdofm_plot = FEM.gnum2gdof(1:3,hm)';

%% independent degrees of freedom (n set)
nIndp = size(obj.G1i,2);
cn = str2num(num2str(obj.C1)');
ncn = size(cn,1);
obj.gdofn = zeros(1,ncn*nIndp);
obj.gdofn_plot = zeros(3,nIndp);
ldofn = zeros(1,ncn*nIndp);
ldofg = 1:6*nIndp;
Li = zeros(3,nIndp);
for j = 1:nIndp
    hnj = find(FEM.gnum == obj.G1i(j));
    if size(hnj,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.G1i(j)),'']); end
    
    obj.xn(:,j) = [FEM.GRID(hnj).X1;FEM.GRID(hnj).X2;FEM.GRID(hnj).X3];
    Li(:,j) = obj.xn(:,j) - obj.xm;
    
    
    % global and local dof
    obj.gdofn((1:ncn)+ncn*(j-1)) = FEM.gnum2gdof(cn,hnj);
        ldofn((1:ncn)+ncn*(j-1)) = ldofg(cn + ncn*(j-1));
    
    % plot indices
    obj.gdofn_plot(:,j) = FEM.gnum2gdof(1:3,hnj);

end

%% following Salinas Theory Manual Version 4.22
L = zeros(1,nIndp);

S = zeros(6*nIndp,6);
for j = 1:nIndp
    L(j) = sqrt( sum( Li(:,j).^2 ) );
    
    S((1:6)+6*(j-1),:) = ...
        [1 0 0   0        Li(3,j) -Li(2,j)
         0 1 0  -Li(3,j)  0        Li(1,j)
         0 0 1   Li(2,j) -Li(1,j)  0      
         0 0 0   1        0        0
         0 0 0   0        1        0 
         0 0 0   0        0        1      ];
end
Lc = sum(L)/nIndp;
Lc2 = Lc^2;
w = [1 1 1 Lc2 Lc2 Lc2];
W = repmat(w,[1 nIndp]);

%% Reduced dof
Snm = S(ldofn,ldofm);
Wn = W(ldofn);

%% Solve
A = Snm.'*diag(Wn)*Snm;
if rank(A) < size(A,1)
    error('Numerical analysis predicts a mechanism in RBE3 ID ',num2str(obj.EID),'.  Additional DOF in C1 may stabalize the element. ');
end
Gqi = A\Snm.'*diag(Wn);
obj.RnRm = [Gqi,-eye(ncn)];

end