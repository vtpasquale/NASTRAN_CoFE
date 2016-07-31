function [obj,obj_prime]= analysis_101(obj,obj_prime)

if nargin > 1
    ndv = size(obj_prime,1);
end

%% Displacements
if nargout < 2
    obj.u = legacy.SOL_101_CoFE(obj.K_G,obj.Gm,obj.p,obj.n,obj.m,obj.nf_g,obj.nf_n);
else
    % Displacements & Design derivatives
    [obj.u,u_prime] = legacy.SOL_101_CoFE(obj.K_G,obj.Gm,obj.p,...
        obj.n,obj.m,obj.nf_g,obj.nf_n,d([obj_prime.K_G]),...
        d([obj_prime.Gm]),d([obj_prime.p]));
    % loop through design varaiables
    for dv = 1:ndv
        obj_prime(dv).u = u_prime(:,dv);
    end
    clear u_prime
end

%% Element Recovery
if obj.CASE.RECOVER == 1
    if nargout < 2
        obj = recover(obj);
    else
        [obj,obj_prime] = recover(obj,obj_prime);
    end
end

end