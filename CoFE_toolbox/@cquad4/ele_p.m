% Function to calculate integration point contributions for cquad4 element mass and stiffness matricies
% Anthony Ricciardi
%
function [kn,ks,mp] = ele_p(obj,xi,eta)

%% shape function evaluations
Ni      = .25*[(1-xi)*(1-eta),(1+xi)*(1-eta),(1+xi)*(1+eta),(1-xi)*(1+eta)];
dNdxii  = .25*[      -(1-eta),       (1-eta),       (1+eta),      -(1+eta)];
dNdetai = .25*[(1-xi)*-1     ,(1+xi)*-1     ,(1+xi)        ,(1-xi)        ];

%% Jacobian
Jac = ...
[ [dNdxii;
   dNdetai]* obj.XE.';
   Ni*[obj.n1,obj.n2,obj.n3,obj.n4].' ];
 
detJ = det(Jac);

%% Rotation matrix
z_i = cross3(Jac(1,:),Jac(2,:))./norm_cs(cross3(Jac(1,:),Jac(2,:)));
x_i = cross3([0 1 0],z_i)./norm_cs(cross3([0 1 0],z_i));
y_i = cross3(z_i,x_i);
T = [x_i;y_i;z_i];

%% Partial derivatives wrt physical coordinates
dNdxzy = T/Jac*[dNdxii; dNdetai; 0 0 0 0];

%% element thickness at location
tg = Ni * obj.t.';

%% calculate strain displacement matrix at the integration point

e1=[dNdxzy(1,1)     0           0;
    0               dNdxzy(2,1) 0; 
    dNdxzy(2,1)     dNdxzy(1,1) 0];

e2=[dNdxzy(1,2)     0           0;
    0               dNdxzy(2,2) 0; 
    dNdxzy(2,2)     dNdxzy(1,2) 0];

e3=[dNdxzy(1,3)     0           0;
    0               dNdxzy(2,3) 0; 
    dNdxzy(2,3)     dNdxzy(1,3) 0];
   
e4=[dNdxzy(1,4)     0           0;
    0               dNdxzy(2,4) 0; 
    dNdxzy(2,4)     dNdxzy(1,4) 0];

s1=[0 0 dNdxzy(2,1) 0    Ni(1) 0
    0 0 dNdxzy(1,1) Ni(1) 0    0];
s2=[0 0 dNdxzy(2,2) 0    Ni(2) 0
    0 0 dNdxzy(1,2) Ni(2) 0    0];
s3=[0 0 dNdxzy(2,3) 0    Ni(3) 0
    0 0 dNdxzy(1,3) Ni(3) 0    0];
s4=[0 0 dNdxzy(2,4) 0    Ni(4) 0
    0 0 dNdxzy(1,4) Ni(4) 0    0];


z3 = zeros(3);
zeta = 1/sqrt(3)*[-1 1];


B1 = [[e1  z3
       z3  .5*tg*zeta(1)*e1
       s1                  ] * [T z3; z3 T*obj.A(:,:,1)],...
      [e2  z3
       z3  .5*tg*zeta(1)*e2
       s2                  ] * [T z3; z3 T*obj.A(:,:,2)],...
      [e3  z3
       z3  .5*tg*zeta(1)*e3
       s3                  ] * [T z3; z3 T*obj.A(:,:,3)],...
      [e4  z3
       z3  .5*tg*zeta(1)*e4
       s4                  ] * [T z3; z3 T*obj.A(:,:,4)]];

B2 = [[e1  z3
       z3  .5*tg*zeta(2)*e1
       s1                  ] * [T z3; z3 T*obj.A(:,:,1)],...
      [e2  z3
       z3  .5*tg*zeta(2)*e2
       s2                  ] * [T z3; z3 T*obj.A(:,:,2)],...
      [e3  z3
       z3  .5*tg*zeta(2)*e3
       s3                  ] * [T z3; z3 T*obj.A(:,:,3)],...
      [e4  z3
       z3  .5*tg*zeta(2)*e4
       s4                  ] * [T z3; z3 T*obj.A(:,:,4)]];
   
%% Stiffness matrix
kn = (B1([1:2,4:5],:).'*obj.G([1:2,4:5],[1:2,4:5])*B1([1:2,4:5],:) + B2([1:2,4:5],:).'*obj.G([1:2,4:5],[1:2,4:5])*B2([1:2,4:5],:)) *.5*tg*detJ;
ks = (B1([3,6:8],:).'*obj.G([3,6:8],[3,6:8])*B1([3,6:8],:) + B2([3,6:8],:).'*obj.G([3,6:8],[3,6:8])*B2([3,6:8],:)) *.5*tg*detJ;

%% Mass matrix
% consistant
mp = (tg*obj.rho + obj.NSM) *(Ni.')*Ni*detJ;

% lumped
% mp = (tg*obj.rho + obj.NSM) *diag(Ni)*detJ;

end
function p = cross3(u,v)
    p = [u(2)*v(3), u(3)*v(1), u(1)*v(2)]-[u(3)*v(2), u(1)*v(3), u(2)*v(1)];
end
%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end