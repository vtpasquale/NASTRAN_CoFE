% CoFE SOL 101 - Linear statics solution and sensitivities w.r.t sizing design variables
% Anthony Ricciardi
%
% Required Inputs:
% K_G  = [ndof,ndof] Global elastic stiffness matrix
% M_G  = [ndof,ndof] Global mass matrix
% Gm  =  [length(m),length(n)] Global multipoint constraint matrix
% p = [ndof,1] Global force vector
% n = [:,1] independent degrees of freedom indexed in g-set
% m = [:,1] dependent degrees of freedom indexed in g-set
% nf_g = [:,1] free (no spc) independent degrees of freedom indexed in g-set
% nf_n = [:,1] free (no spc) independent degrees of freedom indexed in n-set
%
% Optional Inputs (For Design Derivatives):
% K_G_prime = [ndof,ndof*ndv] Derivatives of global elastic stiffness matrix wrt design variables
% Gm_prime  = [length(m),length(n)*ndv] Derivatives of global multipoint constraint matrix
% p_prime   = [ndof,ndv] Derivatives of global force vector
%
% Outputs:
% x       = [ndof,1] Linear static solution 
% x_prime = [ndof,ndv] Derivative of linear static solution  w.r.t design variables
%
function [x,x_prime] = SOL_101_CoFE(K_G,Gm,p,n,m,nf_g,nf_n,K_G_prime,Gm_prime,p_prime)
ndof = size(K_G,1);
x = zeros(ndof,1);

% indepentant degrees of freedom
if isempty(Gm) == 0
    K_Gnn = K_G(n,n) +  K_G(n,m)*Gm + Gm'* K_G(n,m).' + Gm'* K_G(m,m)*Gm;
    Pn = p(n) + Gm'*p(m);
else
    K_Gnn = K_G(n,n);
    Pn = p(n);
end

% solve
x(nf_g) = K_Gnn(nf_n,nf_n)\Pn(nf_n);
if isempty(Gm) == 0
    x(m) = Gm*x(n);
end

%% Sensitivities [optional]
if nargout > 1
    ndv = size(p_prime,2);
    x_prime = zeros(ndof,ndv);
    
    for dv = 1:ndv
        K_G_prime_dv = K_G_prime(:,(1:ndof)+(dv-1)*ndof);
        if isempty(Gm) == 0
            K_Gnn_prime = K_G_prime_dv(n,n) +  K_G_prime_dv(n,m)*Gm + Gm'* K_G_prime_dv(n,m).' + Gm'* K_G_prime_dv(m,m)*Gm; 
            pn_prime = p_prime(n,dv) + Gm'*p_prime(m,dv);
        else
            K_Gnn_prime = K_G_prime_dv(n,n);
            pn_prime = p_prime(n,dv);
        end
        
        x_prime(nf_g,dv) = K_Gnn(nf_n,nf_n)\(pn_prime(nf_n)-K_Gnn_prime(nf_n,nf_n)*x(nf_g));
        
        if isempty(Gm) == 0
            x_prime(m,dv) = Gm*x_prime(n,dv);
        end
    end
end

end
