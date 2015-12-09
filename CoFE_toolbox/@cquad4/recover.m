function [obj,obj_prime] = recover(obj,gnum2gdof,globalDef,obj_prime,globalDef_prime)

% analysis results
elDef = globalDef(obj.gdof);
obj.stress = [crunch(obj.GB1,elDef), crunch(obj.GB2,elDef)];

% Design Derivatives
if nargin > 3
    elDef_prime = globalDef_prime(obj.gdof);
    obj_prime.stress = [crunch_prime(obj.GB1,elDef,d(obj_prime.GB1),elDef_prime), crunch_prime(obj.GB2,elDef,d(obj_prime.GB2),elDef_prime)];
end

end

function stressOut = crunch(G,u)
stress = G*u;
s = [stress(1:3)+stress(4:6);stress(7:8)];
vmStress = sqrt( s(1)^2 - s(1)*s(2) + s(2)^2 + 3*s(3)^2 );
principalAngles = 999;%.5*atand(2*s(3)/(s(1)-s(2)));
major = (s(1)+s(2))/2 + sqrt( ((s(1)-s(2))/2)^2 + s(3)^2);
minor = (s(1)+s(2))/2 - sqrt( ((s(1)-s(2))/2)^2 + s(3)^2);
stressOut = [s;principalAngles;major;minor;vmStress];
end

function stressOut_prime = crunch_prime(G,u,G_prime,u_prime)
stress = G*u;
s = [stress(1:3)+stress(4:6);stress(7:8)];
stress_prime = G*u_prime+G_prime*u;
s_prime = [stress_prime(1:3)+stress_prime(4:6);stress_prime(7:8)];

vmStress_prime = (-s(2)*s_prime(1)+2*s(1)*s_prime(1)-s(1)*s_prime(2)+2*s(2)*s_prime(2)+6*s(3)*s_prime(3))/(2*sqrt(-s(1)*s(2)+s(1)^2+s(2)^2+3*s(3)^2));
principalAngles_prime = 0;
major_prime = (.5*(s(1)-s(2))*(s_prime(1)-s_prime(2))+2*s(3)*s_prime(3))/(2*sqrt(.25*(s(1)-s(2))^2+s(3)^2))+.5*(s_prime(1)+s_prime(2));
minor_prime =-(.5*(s(1)-s(2))*(s_prime(1)-s_prime(2))+2*s(3)*s_prime(3))/(2*sqrt(.25*(s(1)-s(2))^2+s(3)^2))+.5*(s_prime(1)+s_prime(2));
stressOut_prime = [s_prime;principalAngles_prime;major_prime;minor_prime;vmStress_prime];
end