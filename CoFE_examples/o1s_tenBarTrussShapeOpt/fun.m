% Objective function, constrants, and derivatives for optimization
%
function [obj,con] = fun(X,FEM)

FEM = CoFE_design(FEM,X,@X_2_FEM);

% Stress constraints
con = zeros(20,1);
allowableStress = 25000;
con(1:10) =   [FEM.CROD.stress].' - allowableStress;
con(11:20) = -[FEM.CROD.stress].' - allowableStress;

% calculate mass
massDof = 1:6:FEM.ndof; % pick all of one displacement dof
obj = full(sum(sum(FEM.M_G(massDof,massDof))));