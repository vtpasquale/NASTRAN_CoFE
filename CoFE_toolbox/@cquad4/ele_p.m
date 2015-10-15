% function to calculate integration point contributions to cquad4 element mass and stiffness matricies
% Anthony Ricciardi
%
function [kp,mp] = ele_p(obj,i,j)

%%
XI = 1/sqrt(3)*[-1 -1; 1 1];
ETA = 1/sqrt(3)*[-1 1; -1 1];
xi = XI(i,j);
eta = ETA(i,j);

%% Jacobian
Jac = Jacobian(obj,xi,eta);

%% Rotation matrix
z_i = cross3(Jac(1,:),Jac(2,:))./norm_cs(cross3(Jac(1,:),Jac(2,:)));
x_i = cross3(obj.ye,z_i)./norm_cs(cross3(obj.ye,z_i));
y_i = cross3(z_i,x_i);
T = [x_i;y_i;z_i];

%% calculate strain displacement matrix at the integration point

dNdxzy = T/Jac*...
    [dNdxi(obj,1,xi,eta)  dNdxi(obj,2,xi,eta)  dNdxi(obj,3,xi,eta)  dNdxi(obj,4,xi,eta) ;
     dNdeta(obj,1,xi,eta) dNdeta(obj,2,xi,eta) dNdeta(obj,3,xi,eta) dNdeta(obj,4,xi,eta);
     0                    0                    0                    0                  ];

e1=[dNdxzy(1,1)     0           0;
    0               dNdxzy(2,1) 0; 
    dNdxzy(2,1)     dNdxzy(1,1) 0] * T;

e2=[dNdxzy(1,2)     0           0;
    0               dNdxzy(2,2) 0; 
    dNdxzy(2,2)     dNdxzy(1,2) 0] * T;

e3=[dNdxzy(1,3)     0           0;
    0               dNdxzy(2,3) 0; 
    dNdxzy(2,3)     dNdxzy(1,3) 0] * T;
   
e4=[dNdxzy(1,4)     0           0;
    0               dNdxzy(2,4) 0; 
    dNdxzy(2,4)     dNdxzy(1,4) 0] * T;

B = [e1,e2,e3,e4];

%%  
detJ = det(Jac);

%% Stiffness matrix
kp = B.'*obj.G*B *detJ;

%% Mass matrix
Nind= [obj.N(1,xi,eta),obj.N(2,xi,eta),obj.N(3,xi,eta),obj.N(4,xi,eta)];
mp = Nind'*Nind*detJ;

end
function p = cross3(u,v)
    p = [u(2)*v(3), u(3)*v(1), u(1)*v(2)]-[u(3)*v(2), u(1)*v(3), u(2)*v(1)];
end
%% complex step friendly norm
function p = norm_cs(v)
    p = sqrt(v(1).^2+v(2).^2+v(3).^2);
end