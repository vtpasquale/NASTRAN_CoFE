% Function to execute CoFE analysis
% Anthony Ricciardi
%
% Input
% FEM = [1x1 fem] Finite element model and solution object
% X = [1xndv real] vector of design variables
% X_2_FEM = [function handle] function to update FEM object based on design variable values 
%
% Outputs
% FEM = [1x1 fem] Finite element model and solution object
% FEM_prime = [1xnumber of design variables fem] FEM object array with model and solution design derivatives
%
function [FEM,FEM_prime] = CoFE_design(FEM,X,X_2_FEM)

if nargout < 2 % no design derivatives
    FEM = update_design(FEM,X,X_2_FEM);
    FEM= analysis(FEM);
    
else % with design derivatives
    [FEM, FEM_prime] = FEM.update_design(X,X_2_FEM);
    [FEM, FEM_prime] = FEM.analysis(FEM_prime);
end

end

