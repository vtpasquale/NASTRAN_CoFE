function [obj,obj_prime] = recover(obj,gnum2gdof,globalDef,obj_prime,globalDef_prime)

% analysis results
elDef = globalDef(obj.gdof);

obj.stress = [crunch(obj.GB1,elDef), crunch(obj.GB2,elDef)];

% 
% % Design Derivatives
% if nargin > 3
%     elDef_prime = globalDef_prime([gnum2gdof(:,obj.G1);gnum2gdof(:,obj.G2)]);
%     obj_prime.force = (obj.R*obj.ke)*elDef_prime + ...
%         (d(obj_prime.R)*obj.ke + obj.R*d(obj_prime.ke))*elDef;
%     obj_prime.stress = d(obj_prime.force_stress)*obj.force + ...
%         obj.force_stress*obj_prime.force;
% end

end

function stressOut = crunch(G,u)
stress = G*u;
s = [stress(1:3)+stress(4:6);stress(7:8)];
vmStress = sqrt( s(1)^2 - s(1)*s(2) + s(2)^2 + 3*s(3)^2 );
principalAngles = .5*atand(2*s(3)/(s(1)-s(2)));
major = (s(1)+s(2))/2 + sqrt( ((s(1)-s(2))/2)^2 + s(3)^2);
minor = (s(1)+s(2))/2 - sqrt( ((s(1)-s(2))/2)^2 + s(3)^2);
stressOut = [s;principalAngles;major;minor;vmStress];
end
