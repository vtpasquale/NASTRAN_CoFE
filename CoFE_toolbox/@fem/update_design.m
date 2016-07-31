function [obj,obj_prime] = update_design(obj0,X,X_2_FEM)

% update design
obj0 = X_2_FEM(obj0,X);
obj = obj0.assemble(obj0.CASE);

if nargout > 1
    % number of design varaibles
    ndv = size(X,1);
    
    % number of subcases
    nsc = size(obj,2);
    
    % initialize obj_prime array of fem objects
    obj_prime(ndv,nsc) = obj0(1);
    
    % complex step size
    dCs = eps;
        
    % loop through design varaiables
    for dv = 1:ndv
        Xdv = X;
        Xdv(dv) = Xdv(dv) + 1i*dCs;
        obj_prime0 = X_2_FEM(obj0,Xdv);
        obj_prime(dv,1:nsc) = obj_prime0.assemble(obj0.CASE);
    end

end