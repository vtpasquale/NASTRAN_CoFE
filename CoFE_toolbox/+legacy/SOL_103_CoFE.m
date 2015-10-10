% CoFE SOL 103 - Vibration eigenpair solution and sensitivities w.r.t sizing design variables
% Anthony Ricciardi
%
% Required Inputs:
% K_G  = [ndof,ndof] Global elastic stiffness matrix
% M_G  = [ndof,ndof] Global mass matrix
% Gm  =  [length(m),length(n)] Global multipoint constraint matrix
% nModes = [scalar] number of vibration eigenpair solutions
% nf_g = [:,1] free (no spc) independent degrees of freedom indexed in g-set
% nf_n = [:,1] free (no spc) independent degrees of freedom indexed in n-set
% n = [:,1] independent degrees of freedom indexed in g-set
% m = [:,1] dependent degrees of freedom indexed in g-set
% ndof = [scalar] number of degrees of freedom in g-set
%
% Optional Inputs (For Sensitivities):
% K_G_prime = [ndof,ndof,ndv] Derivative of global elastic stiffness matrix wrt design variables
% M_G_prime = [ndof,dof,ndv] Derivative of global mass matrix wrt design variables
%
% Outputs:
% xm = [ndof,nModes] Vibration mode shapes, mass normalized
% wHz = [nModes,1] Vibration frequencies in Hertz
% xm_prime = [ndof,nModes,ndv] Vibration mode shape sensitivities
% wHz_prime = [nModes,ndv] Sensitivities of vibration frequency in Hertz
%
function [xm,wHz,xm_prime,wHz_prime] = SOL_103_CoFE(K_G,M_G,Gm,nModes,nf_n,nf_g,n,m,ndof,K_G_prime,M_G_prime,Gm_prime)

%% Solve eigenvalue/eigenvector problem
if isempty(Gm) == 0
    M_Gnn = M_G(n,n) +  M_G(n,m)*Gm + Gm.'* M_G(n,m).' + Gm.'* M_G(m,m)*Gm;
    K_Gnn = K_G(n,n) +  K_G(n,m)*Gm + Gm.'* K_G(n,m).' + Gm.'* K_G(m,m)*Gm;
else
    M_Gnn = M_G(n,n);
    K_Gnn = K_G(n,n);
end

%%
[V,Ds] = eigs(sparse( K_Gnn(nf_n,nf_n)\M_Gnn(nf_n,nf_n) ),nModes);
D = diag(Ds).^-1;
wHz = sqrt(D)./(2*pi);
xm = zeros(ndof,nModes);
xm(nf_g,:) = V;

if isempty(Gm) == 0
    xm(m,:) = Gm*xm(n,:);
end

%% mass normalize eigenvectors (required for Lee and Jung sensitivity method)
for mn = 1:nModes
    % there is a problem... xm(:,1:nModes)'.*xm(:,1:nModes) = -xm(:,1:nModes)'.*-xm(:,1:nModes)
    % so the sign from the solution can reverse without warning.
    % This is a problem for numerical derivatives.
    % This section is an attempt to keep sign consistent.
    if sum(xm(:,mn)) < 0
        xm(:,mn) = -xm(:,mn);
    end
    % Mass normalize
    xm(:,mn) = xm(:,mn)./sqrt(diag(xm(:,mn).'*M_G*xm(:,mn)));
end

%% Eigenpair Sensitivities (Optional)
if nargout > 2
    % check for repeated eigenvalues
    if size(unique(round(10000*D)),1) < nModes
        error(['You''ve asked for the derivatives of eigenvectors', ...
        'cooresponding to repeated eigenvalues. This is unsupported.  See xxxxx '])
    end
    ndv = size(K_G_prime,2)/ndof;
    [D_prime,xm_prime] = legacy.leeAndJungDistinctEigenPairDerivatives(...
        D,xm,K_Gnn,M_Gnn,Gm,nModes,nf_n,nf_g,n,m,ndof,ndv,K_G_prime,M_G_prime,Gm_prime);   
    wHz_prime = D_prime./(4*pi*sqrt( repmat(D,[1,ndv]) ));
end
