function [obj,obj_prime] = recover(obj,FEM,obj_prime,FEM_prime)

%% Analysis Results
u_e = FEM.u(obj.gdof,:);
FEMCASE=FEM.CASE; % speeds up execution

% force
if FEMCASE.FORCE || FEMCASE.STRESS || FEMCASE.STRAIN
    obj.force = ([0 0 0 0 0 0 1 0 0 0 0 0]*obj.R*obj.ke*u_e).';
end

% stress
if FEMCASE.STRESS || FEMCASE.STRAIN
    obj.stress = obj.force_stress*obj.force;
end

% strains
if FEMCASE.STRAIN
    obj.strain(:,:,1) = obj.stress_strain(1)*obj.stress;
    obj.strain(:,:,2) = obj.stress_strain(2)*obj.stress; 
end

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
    
    % force
    if FEMCASE.FORCE || FEMCASE.STRESS || FEMCASE.STRAIN
        obj_prime.force = (...
            [0 0 0 0 0 0 1 0 0 0 0 0]*(...
            (obj.R*obj.ke)*u_e_prime + ...
            (d(obj_prime.R)*obj.ke + obj.R*d(obj_prime.ke))*u_e ...
            ) ).';
    end
    
    % stress
    if FEMCASE.STRESS || FEMCASE.STRAIN
        obj_prime.stress = d(obj_prime.force_stress)*obj.force + ...
                            obj.force_stress*obj_prime.force;
    end
    
    % strain
    if FEMCASE.STRAIN
        obj_prime.strain(:,:,1) = d(obj_prime.stress_strain(1))*obj.stress + obj.stress_strain(1)*obj_prime.stress;
        obj_prime.strain(:,:,2) = d(obj_prime.stress_strain(2))*obj.stress + obj.stress_strain(2)*obj_prime.stress;
    end
    
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

