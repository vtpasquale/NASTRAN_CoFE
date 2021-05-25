% Function to calculate integration point contributions for cquad4 element mass and stiffness matricies
% Anthony Ricciardi
%
function  [kn,ks,mp,BB,BT,tg] = ele_p(obj,xi,eta,matrixOption)
kn=[];
ks=[];
mp=[];

%% shape function evaluations
Ni      = [1-xi-eta, xi, eta];
dNdxii  = [-1, 1, 0];
dNdetai = [-1, 0, 1];

%% Jacobian
% % % % 3D
% % % Jac = [ [dNdxii;
% % %          dNdetai]* obj.XE.';
% % %          Ni*[0, 0, 1; 0, 0, 1; 0, 0, 1] ];

% 2D
Jac = [dNdxii;
       dNdetai] * obj.XE(1:2,:).';
 
area = 0.5*det(Jac);

%% Partial derivatives wrt physical coordinates
% % % % 3D
% % % dNdxzy = Jac\[dNdxii; dNdetai; 0 0 0];

% 2D
dNdxzy = Jac\[dNdxii; dNdetai];


%% Element thickness at integration point
tg = Ni * obj.t.';

%% Calculate strain displacement matrix at xi & eta

e1=[dNdxzy(1,1)     0           0;
    0               dNdxzy(2,1) 0; 
    dNdxzy(2,1)     dNdxzy(1,1) 0];

e2=[dNdxzy(1,2)     0           0;
    0               dNdxzy(2,2) 0; 
    dNdxzy(2,2)     dNdxzy(1,2) 0];

e3=[dNdxzy(1,3)     0           0;
    0               dNdxzy(2,3) 0; 
    dNdxzy(2,3)     dNdxzy(1,3) 0];


s1=[0 0 dNdxzy(2,1) 0    Ni(1) 0
    0 0 dNdxzy(1,1) Ni(1) 0    0];
s2=[0 0 dNdxzy(2,2) 0    Ni(2) 0
    0 0 dNdxzy(1,2) Ni(2) 0    0];
s3=[0 0 dNdxzy(2,3) 0    Ni(3) 0
    0 0 dNdxzy(1,3) Ni(3) 0    0];

z3 = zeros(3);

%% Element matricies
if matrixOption == 1 || matrixOption == 2
    
    B  = [[e1  z3
        z3  e1
        s1                  ] * obj.TAI,...
        [e2  z3
        z3  e2
        s2                  ] * obj.TAI,...
        [e3  z3
        z3  e3
        s3                  ] * obj.TAI ];
    
    %% Modify constitutive (stress-strain) matrix for bending
    G = obj.G;
    G(4:6,4:6) = tg^2/12*G(4:6,4:6); % << not tg^3/12 because membrane and shear terms dimensionalized with tg in integral lines
    
    %% Stiffness matrix contributions at integration point
    if matrixOption == 2
        % shear stiffness
        ks = B([3,6:8]  ,:).'*G([3,6:8]  ,[3,6:8]  )*B([3,6:8]  ,:) *tg*area;
    end
    
    if matrixOption == 1
        % normal stiffness
        kn = B([1:2,4:5],:).'*G([1:2,4:5],[1:2,4:5])*B([1:2,4:5],:) *tg*area;
    end
    
    %% Mass matrix
    % consistant
    mp = (tg*obj.rho + obj.NSM)*(Ni.')*Ni*area;
    
    

    % lumped
    % mp = (tg*obj.rho + obj.NSM) *diag(Ni)*detJ;
end

%% strain-displacement matrix at xi & eta
if nargout > 3
   zeta = [-1 1];
   BB=[[e1  z3
        z3  .5*tg*zeta(1)*e1
        s1                  ] * obj.TAI,...
        [e2  z3
        z3  .5*tg*zeta(1)*e2
        s2                  ] * obj.TAI,...
        [e3  z3
        z3  .5*tg*zeta(1)*e3
        s3                  ] * obj.TAI ];
   BT=[[e1  z3
        z3  .5*tg*zeta(2)*e1
        s1                  ] * obj.TAI,...
        [e2  z3
        z3  .5*tg*zeta(2)*e2
        s2                  ] * obj.TAI,...
        [e3  z3
        z3  .5*tg*zeta(2)*e3
        s3                  ] * obj.TAI ];
end


end

function p = cross3(u,v)
    p = [u(2)*v(3), u(3)*v(1), u(1)*v(2)]-[u(3)*v(2), u(1)*v(3), u(2)*v(1)];
end
%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end