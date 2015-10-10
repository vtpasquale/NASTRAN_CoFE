function [obj,obj_prime] = recover(obj,gnum2gdof,globalDef,obj_prime,globalDef_prime)

% % analysis results
% elDef = globalDef([gnum2gdof(:,obj.G1);gnum2gdof(:,obj.G2)]) ;
% obj.force = obj.R*obj.ke*elDef;
% obj.stress = obj.force_stress*obj.force;
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

