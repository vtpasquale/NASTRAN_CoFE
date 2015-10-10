% rotation matrix
function val = TIE(obj,xi,eta)
J = Jacobian(obj,xi,eta);

z_i = cross(J(1,:),J(2,:))./norm(cross(J(1,:),J(2,:)));
x_i = cross(obj.ye,z_i)./norm(cross(obj.ye,z_i));
y_i = cross(z_i,x_i);

val = [x_i;y_i;z_i];