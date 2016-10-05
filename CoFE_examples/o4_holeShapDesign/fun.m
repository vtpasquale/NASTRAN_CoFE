% Objective function, constrants, and derivatives for optimization
%
function [obj,con] = fun(X,FEM)

FEM = CoFE_design(FEM,X,@X_2_FEM);

% von Mises stress at all recover points for all elements
svmAll = [FEM.CQUAD4.vonMisesStress];

% pick von Mises at element center - bottom face
svm = svmAll(1:10:270);

% Stress constraints
allowableStress = 3.1E4;
con =   svm.' - allowableStress;

% calculate mass
massDof = 1:6:FEM.ndof; % pick all of one displacement dof
obj = full(sum(sum(FEM.M_G(massDof,massDof))));