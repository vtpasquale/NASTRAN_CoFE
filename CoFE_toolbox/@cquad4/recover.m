function [obj,obj_prime] = recover(obj,FEM,obj_prime,FEM_prime)

% analysis results
u_e = FEM.u(obj.gdof,:);
nm = size(u_e,2);
FEMCASE=FEM.CASE; % speeds up execution

if nargin < 3
    % element kinetic energy
    if FEMCASE.EKE && FEMCASE.SOL == 103
        obj.eke= (pi*FEM.fHz).*diag(u_e.'*obj.me*u_e);
    end
    
    % element strain energy
    if FEMCASE.ESE
        obj.ese=.5*diag(u_e.'*obj.ke*u_e);
    end
    
    if FEMCASE.STRESS || FEMCASE.STRAIN
        % initialize
        obj.voigtStress = zeros(6,nm,10);
        obj.voigtStrain = zeros(6,nm,10);
        
        % center bottom
        [ecb,scb] = processResponse(obj.G,obj.CBB,u_e);
        obj.voigtStrain(:,:,1) = ecb;
        obj.voigtStress(:,:,1) = scb;
        
        % center top
        [ect,sct] = processResponse(obj.G,obj.CBT,u_e);
        obj.voigtStrain(:,:,2) = ect;
        obj.voigtStress(:,:,2) = sct;
        
        % responses at nodes
        [e2,s2] = processResponse(obj.G,obj.N1BB,u_e,ecb,scb);
        obj.voigtStrain(:,:,3) = e2;
        obj.voigtStress(:,:,3) = s2;
        [e2,s2] = processResponse(obj.G,obj.N1BT,u_e,ect,sct);
        obj.voigtStrain(:,:,4) = e2;
        obj.voigtStress(:,:,4) = s2;
        [e2,s2] = processResponse(obj.G,obj.N2BB,u_e,ecb,scb);
        obj.voigtStrain(:,:,5) = e2;
        obj.voigtStress(:,:,5) = s2;
        [e2,s2] = processResponse(obj.G,obj.N2BT,u_e,ect,sct);
        obj.voigtStrain(:,:,6) = e2;
        obj.voigtStress(:,:,6) = s2;
        [e2,s2] = processResponse(obj.G,obj.N3BB,u_e,ecb,scb);
        obj.voigtStrain(:,:,7) = e2;
        obj.voigtStress(:,:,7) = s2;
        [e2,s2] = processResponse(obj.G,obj.N3BT,u_e,ect,sct);
        obj.voigtStrain(:,:,8) = e2;
        obj.voigtStress(:,:,8) = s2;
        [e2,s2] = processResponse(obj.G,obj.N4BB,u_e,ecb,scb);
        obj.voigtStrain(:,:,9) = e2;
        obj.voigtStress(:,:,9) = s2;
        [e2,s2] = processResponse(obj.G,obj.N4BT,u_e,ect,sct);
        obj.voigtStrain(:,:,10) = e2;
        obj.voigtStress(:,:,10) = s2;
        
    end
    
else
    %% Design Derivatives
    obj_prime.voigtStrain_fromAnalysis = obj.voigtStrain;
    obj_prime.voigtStress_fromAnalysis = obj.voigtStress;
    
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
    
    if FEMCASE.STRESS || FEMCASE.STRAIN
        
        % initialize
        obj_prime.voigtStress = zeros(6,nm,10);
        obj_prime.voigtStrain = zeros(6,nm,10);
        G_prime = d(obj_prime.G);
        
        % center bottom
        [ecb,scb] = processResponse_prime(obj.G,obj.CBB,u_e,...
            G_prime,d(obj_prime.CBB),u_e_prime);
        obj_prime.voigtStrain(:,:,1) = ecb;
        obj_prime.voigtStress(:,:,1) = scb;
        
        % center top
        [ect,sct] = processResponse_prime(obj.G,obj.CBT,u_e,...
            G_prime,d(obj_prime.CBT),u_e_prime);
        obj_prime.voigtStrain(:,:,2) = ect;
        obj_prime.voigtStress(:,:,2) = sct;
        
        % responses at nodes
        [e2,s2] = processResponse_prime(obj.G,obj.N1BB,u_e,...
            G_prime,d(obj_prime.N1BB),u_e_prime,...
            ecb,scb);
        obj_prime.voigtStrain(:,:,3) = e2;
        obj_prime.voigtStress(:,:,3) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N1BT,u_e,...
            G_prime,d(obj_prime.N1BT),u_e_prime,...
            ect,sct);
        obj_prime.voigtStrain(:,:,4) = e2;
        obj_prime.voigtStress(:,:,4) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N2BB,u_e,...
            G_prime,d(obj_prime.N2BB),u_e_prime,...
            ecb,scb);
        obj_prime.voigtStrain(:,:,5) = e2;
        obj_prime.voigtStress(:,:,5) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N2BT,u_e,...
            G_prime,d(obj_prime.N2BT),u_e_prime,...
            ect,sct);
        obj_prime.voigtStrain(:,:,6) = e2;
        obj_prime.voigtStress(:,:,6) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N3BB,u_e,...
            G_prime,d(obj_prime.N3BB),u_e_prime,...
            ecb,scb);
        obj_prime.voigtStrain(:,:,7) = e2;
        obj_prime.voigtStress(:,:,7) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N3BT,u_e,...
            G_prime,d(obj_prime.N3BT),u_e_prime,...
            ect,sct);
        obj_prime.voigtStrain(:,:,8) = e2;
        obj_prime.voigtStress(:,:,8) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N4BB,u_e,...
            G_prime,d(obj_prime.N4BB),u_e_prime,...
            ecb,scb);
        obj_prime.voigtStrain(:,:,9) = e2;
        obj_prime.voigtStress(:,:,9) = s2;
        
        [e2,s2] = processResponse_prime(obj.G,obj.N4BT,u_e,...
            G_prime,d(obj_prime.N4BT),u_e_prime,...
            ect,sct);
        obj_prime.voigtStrain(:,:,10) = e2;
        obj_prime.voigtStress(:,:,10) = s2;
        
    end
    
end

end

function [e2,s2] = processResponse(G,B,U,ec,sc)
e1 = B*U;
s1 = G*e1;

if nargin >3 % use reduced order integration for shear stress and strain
    e2(4:6,:)=ec(4:6,:);
    s2(4:6,:)=sc(4:6,:);
else
    e2(4:6,:)= [e1(7:8,:);e1(3,:)+e1(6,:)];
    s2(4:6,:)= [s1(7:8,:);s1(3,:)+s1(6,:)];
end
e2(1:2,:)= e1(1:2,:)+e1(4:5,:);
s2(1:2,:)= s1(1:2,:)+s1(4:5,:);

end

function [e2_prime,s2_prime] = processResponse_prime(G,B,U,G_prime,B_prime,U_prime,ec_prime,sc_prime)
e1_prime = B_prime*U + B*U_prime;
s1_prime = G_prime*B*U + G*e1_prime;

if nargin >6 % use reduced order integration for shear stress and strain
    e2_prime(4:6,:)=ec_prime(4:6,:);
    s2_prime(4:6,:)=sc_prime(4:6,:);
else
    e2_prime(4:6,:)= [e1_prime(7:8,:);e1_prime(3,:)+e1_prime(6,:)];
    s2_prime(4:6,:)= [s1_prime(7:8,:);s1_prime(3,:)+s1_prime(6,:)];
end
e2_prime(1:2,:)= e1_prime(1:2,:)+e1_prime(4:5,:);
s2_prime(1:2,:)= s1_prime(1:2,:)+s1_prime(4:5,:);

end