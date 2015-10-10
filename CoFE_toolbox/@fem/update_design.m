function [obj,obj_prime] = update_design(obj0,X,X_2_FEM)

% update design
obj = X_2_FEM(obj0,X);
obj = obj.assemble();

if nargout > 1
    % number of design varaibles
    ndv = size(X,1);
    
    % initialize design derivative objects
    obj_prime(1:ndv) = obj0;
    
    % complex step size
    dCs = eps;
    
    % loop through design varaiables
    for dv = 1:ndv
        Xdv = X;
        Xdv(dv) = Xdv(dv) + 1i*dCs;
        obj_prime(dv) = X_2_FEM(obj_prime(dv),Xdv);
        obj_prime(dv) = obj_prime(dv).assemble();
    end
    
end