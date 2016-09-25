function [obj,obj_prime] = recover(obj,FEM,obj_prime,FEM_prime)

%% Analysis Results
u_e = FEM.u(obj.gdof,:);
FEMCASE=FEM.CASE; % speeds up execution

% element kinetic energy
if FEMCASE.EKE && FEMCASE.SOL == 103
    obj.eke= (pi*FEM.fHz).*diag(u_e.'*obj.me*u_e);
end

% element strain energy
if FEMCASE.ESE
    obj.ese=.5*diag(u_e.'*obj.ke*u_e);
end


%% Design Sensitivities
if nargin > 2
    u_e_prime = FEM_prime.u(obj.gdof,:);
    
    % element kinetic energy
    if FEMCASE.EKE && FEMCASE.SOL == 103
        obj_prime.eke= pi*FEM_prime.fHz.*diag(u_e.'*obj.me*u_e) + ...
            pi*FEM.fHz.*diag(u_e.'*d(obj_prime.me)*u_e + 2*u_e.'*obj.me*u_e_prime);
    end
    
    % element strain energy
    if FEMCASE.ESE
        obj_prime.ese= .5*diag(u_e.'*d(obj_prime.ke)*u_e + 2*u_e.'*obj.ke*u_e_prime);
    end

end

