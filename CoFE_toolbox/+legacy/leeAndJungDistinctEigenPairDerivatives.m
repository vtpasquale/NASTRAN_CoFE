% Solve distinct eigenpair sensitivities using Lee and Jung Method (Mass Normalized)
% Anthony Ricciardi
%
% Inputs:
% xm = [ndof,nModes] Mode shapes from solution
% D = [nModes] Eigenvalues from solution
% K_Gnn  = [length(n),length(n)] Elastic stiffness matrix of independent dof
% M_Gnn  = [length(n),length(n)] Mass matrix of independent dof
% Gm  =  [length(m),length(n)] Global multipoint constraint matrix
% nModes = [scalar] number of vibration eigenpair solutions
% nf_g = [:,1] free (no spc) independent degrees of freedom indexed in g-set
% nf_n = [:,1] free (no spc) independent degrees of freedom indexed in n-set
% n = [:,1] independent degrees of freedom indexed in g-set
% m = [:,1] dependent degrees of freedom indexed in g-set
% ndof = [scalar] number of degrees of freedom in g-set
% ndv = [scalar] number of design variables
% K_G_prime = [ndof,ndof*ndv] Derivatives of global elastic stiffness matrix wrt design variables
% M_G_prime = [ndof,dof*ndv] Derivatives of global mass matrix wrt design variables
%
% Outputs:
% xm_prime = [ndof,nModes,ndv] Mode shape sensitivities
% D_prime = [nModes,ndv] Eigenvalue sensitivities
%
function [D_prime,xm_prime] = leeAndJungDistinctEigenPairDerivatives(D,xm,K_Gnn,M_Gnn,Gm,nModes,nf_n,nf_g,n,m,ndof,ndv,K_G_prime,M_G_prime,Gm_prime)

nu = length(nf_n);
xm_prime = zeros(ndof,nModes,ndv);
D_prime = zeros(nModes,ndv);

for dv = 1:ndv
    K_G_prime_dv = K_G_prime(:,(1:ndof)+(dv-1)*ndof);
    M_G_prime_dv = M_G_prime(:,(1:ndof)+(dv-1)*ndof);
    
    if isempty(Gm) == 0
        K_Gnn_prime = K_G_prime_dv(n,n) +  K_G_prime_dv(n,m)*Gm + Gm'* K_G_prime_dv(n,m).' + Gm'* K_G_prime_dv(m,m)*Gm;
        M_Gnn_prime = M_G_prime_dv(n,n) +  M_G_prime_dv(n,m)*Gm + Gm'* M_G_prime_dv(n,m).' + Gm'* M_G_prime_dv(m,m)*Gm;
    else
        K_Gnn_prime = K_G_prime_dv(n,n);
        M_Gnn_prime = M_G_prime_dv(n,n);
    end
    
    for mn = 1:nModes
        Kstar = [K_Gnn(nf_n,nf_n)-D(mn)*M_Gnn(nf_n,nf_n), - M_Gnn(nf_n,nf_n)*xm(nf_g,mn);
            -xm(nf_g,mn).'*M_Gnn(nf_n,nf_n), 0];        
        fi = [-(K_Gnn_prime(nf_n,nf_n)-D(mn)*M_Gnn_prime(nf_n,nf_n))*xm(nf_g,mn);
            .5*xm(nf_g,mn).'*M_Gnn_prime(nf_n,nf_n)*xm(nf_g,mn) ];
        xm_D_prime = Kstar\fi;
        
        D_prime(mn,dv) = xm_D_prime(nu+1);
        xm_prime(nf_g,mn,dv) = xm_D_prime(1:nu);
        
        if isempty(Gm) == 0
            xm_prime(m,mn,dv) = Gm*xm_prime(n,mn,dv);
        end
        
    end
end
