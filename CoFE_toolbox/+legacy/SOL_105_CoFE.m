% CoFE SOL 105 - Buckling eigenpair solution and sensitivities w.r.t sizing design variables
% Anthony Ricciardi
%
% Required Inputs:
% x = [ndof,1] Linear statics solution 
% FEM [Cell Structured Data] finite element model data
%
% Ke_g = CBEAM element elastic stiffness matrices [12x12xnumEle]
% KDxx_g = CBEAM element differential stiffness matrices [12x12xnumEle]
% crod_ke_g = CROD element elastic stiffness matrices [12x12xnumEle]
% crod_kdp_e = CROD element differential stiffness matrices [12x12xnumEle]
%
% Gm  =  [length(m),length(n)] Global multipoint constraint matrix
% nModes = [scalar] number of vibration eigenpair solutions
% nf_g = [:,1] free (no spc) independent degrees of freedom indexed in g-set
% nf_n = [:,1] free (no spc) independent degrees of freedom indexed in n-set
% n = [:,1] independent degrees of freedom indexed in g-set
% m = [:,1] dependent degrees of freedom indexed in g-set
% ndof = [scalar] number of degrees of freedom in g-set
%
% Optional Inputs (For Design Derivatives):
% K_G_prime = [ndof,ndof*ndv] Derivatives of global elastic stiffness matrix wrt design variables
% KD_G_prime = [ndof,ndof*ndv] Derivatives of global elastic stiffness matrix wrt design variables
% Gm_prime  = [length(m),length(n)*ndv] Derivatives of global multipoint constraint matrix
%
% Outputs:
% xbm = [ndof,nModes] Buckling mode shapes, stiffness normalized
% Db = [nModes,1] Buckling eigenvalues
% xbm_prime = [ndof,nModes,ndv]  Buckling mode shape sensitivities
% Db_prime = [nModes,ndv] Sensitivities buckling eigenvalues
%
function [xb,Db,xb_prime,Db_prime] = SOL_105_CoFE(...
    K_G,KD_G,Gm,nModes,nf_n,nf_g,n,m,ndof,K_G_prime,KD_G_prime,Gm_prime)

%% Solve
% independent degrees of freedom
if isempty(Gm) == 0
    KD_Gnn = KD_G(n,n) +  KD_G(n,m)*Gm + Gm'* KD_G(n,m).' + Gm'* KD_G(m,m)*Gm;
    K_Gnn =  K_G(n,n)  +  K_G(n,m)*Gm  + Gm'* K_G(n,m).'  + Gm'* K_G(m,m)*Gm;
else
    KD_Gnn = KD_G(n,n);
    K_Gnn =  K_G(n,n); 
end
    
% Solve Buckling Eigenvalue Problem 
[Vb,Db] = eigs(K_Gnn(nf_n,nf_n)\KD_Gnn(nf_n,nf_n),nModes);
Db = -diag(Db).^-1;
[~, ind]= sort(abs(real(Db)));
Db = Db(ind);

xb = zeros(ndof,size(Db,1));
xb(nf_g,:) = Vb(:,ind);
if isempty(Gm) == 0
    xb(m,:) = Gm*xb(n,:);
end

%% Stiffness Normalize (Required for Lee and Jung sensitivity method)
% make  xbm(:,1:nModes)'*(K_G)*xbm(:,1:nModes) = eye(nModes)
for mn = 1:nModes
    
    % there is a problem... xbm(:,1:nModes)'.*xbm(:,1:nModes) = -xbm(:,1:nModes)'.*-xbm(:,1:nModes)
    % so the sign from the solution can reverse without warning. 
    % This is a problem for numerical derivatives.
    % This section is an attempt to keep sign consistent.
    if sum(xb(:,mn)) < 0
        xb(:,mn) = -xb(:,mn);
    end
    % Stiffness normalize
    one =  xb(:,mn).'*(K_G)*xb(:,mn);
    xb(:,mn) = 1/sqrt(one)  * xb(:,mn);
end

%% Eigenpair Sensitivities (Optional)
% Stiffness normalized analogous to M_Gnn = K_Gnn, M_G_prime = K_G_prime,
% K_Gnn = KD_Gnn, K_G_prime = KD_G_prime
if nargout > 2
    
    % check for repeated eigenvalues
    if size(unique(round(10000*Db)),1) < nModes
        error(['You''ve asked for the derivatives of eigenvectors', ...
        'cooresponding to repeated eigenvalues. This is unsupported.  See xxxxx '])
    end
    
    ndv = size(K_G_prime,2)/ndof;
    [Db_prime_inv,xb_prime] = legacy.leeAndJungDistinctEigenPairDerivatives(...
        -Db.^-1,xb,KD_Gnn,K_Gnn,Gm,nModes,nf_n,nf_g,n,m,ndof,ndv,KD_G_prime,K_G_prime,Gm_prime);  
    Db_prime =  Db_prime_inv.*repmat(Db,[1,ndv]).^2;
end

end
