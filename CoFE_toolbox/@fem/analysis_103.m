function [obj,obj_prime]= analysis_103(obj,obj_prime)

if nargin > 1
    ndv = size(obj_prime,1);
end

%% Determine number of roots desired from EIGRL input cooresponding to
% the METHOD specified in the case control
if isempty(obj.CASE.METHOD) ~= 0; error('CASE.METHOD must be specified for SOL = 103 cases.'); end
NDn = find(obj.CASE.METHOD == [obj.EIGRL.SID]);
if size(NDn,2)~=1; error(['There should be one and only one EIGRL with SID = ',num2str(obj.CASE.METHOD),'']); end
obj.ND = obj.EIGRL(NDn).ND;
clear NDn

%% Solution
if nargout < 2
    [obj.u,obj.fHz] = legacy.SOL_103_CoFE(obj.K_G,obj.M_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,obj.ndof);

else % Design derivatives
    [obj.u,obj.fHz,u_prime,fHz_prime] = legacy.SOL_103_CoFE(...
        obj.K_G,obj.M_G,obj.Gm,obj.ND,obj.nf_n,obj.nf_g,obj.n,obj.m,...
        obj.ndof,d([obj_prime.K_G]),d([obj_prime.M_G]),...
        d([obj_prime.Gm]));
    
    % loop through design varaiables
    for dv = 1:ndv
        obj_prime(dv).u = u_prime(:,:,dv);
        obj_prime(dv).fHz = fHz_prime(:,dv);
    end
    clear u_prime fHz_prime
end

%% Element Recovery
if obj.CASE.RECOVER == 1
    if nargout < 2
        obj = recover(obj);
    else
        [obj,obj_prime] = recover(obj,obj_prime);
    end
end

