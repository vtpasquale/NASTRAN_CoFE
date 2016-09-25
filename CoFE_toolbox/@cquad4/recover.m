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
    
    %% Analysis
    %     % response at element center point
    %     obj.centerBot = processResponse(obj.G,obj.CBB,u_e);
    %     obj.centerTop    = processResponse(obj.G,obj.CBT,u_e);
    %
    %     % response at nodes
    %     obj.N1Bot = processResponse(obj.G,obj.N1BB,u_e,obj.centerBot);
    %     obj.N1Top = processResponse(obj.G,obj.N1BT,u_e,obj.centerTop);
    %     obj.N2Bot = processResponse(obj.G,obj.N2BB,u_e,obj.centerBot);
    %     obj.N2Top = processResponse(obj.G,obj.N2BT,u_e,obj.centerTop);
    %     obj.N3Bot = processResponse(obj.G,obj.N3BB,u_e,obj.centerBot);
    %     obj.N3Top = processResponse(obj.G,obj.N3BT,u_e,obj.centerTop);
    %     obj.N4Bot = processResponse(obj.G,obj.N4BB,u_e,obj.centerBot);
    %     obj.N4Top = processResponse(obj.G,obj.N4BT,u_e,obj.centerTop);
    
else
    %% Design Derivatives
    u_e_prime = globalDef_prime(obj.gdof);
    
    % response at element center point
    obj_prime.centerBot = stressPoint;
    obj_prime.centerTop = stressPoint;
    % preload analysis results
    obj_prime.centerBot.stress_from_analysis=obj.centerBottom.stress;
    obj_prime.centerTop.stress_from_analysis=obj.centerTop.stress;
    % stress derivatives
    s1 = obj.GB1*u_e_prime+d(obj_prime.GB1)*u_e;
    s2 = [s1(1:2)+s1(4:5);0;s1(3)+s1(6);s1(7:8)];
    obj_prime.centerBottom.stress = s2;
    s1 = obj.GB2*u_e_prime+d(obj_prime.GB2)*u_e;
    s2 = [s1(1:2)+s1(4:5);0;s1(3)+s1(6);s1(7:8)];
    obj_prime.centerBottom.stress = s2;
    
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