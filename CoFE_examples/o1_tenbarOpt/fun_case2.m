% Objective function, constrants, and derivatives for optimization
%
function [objective,con] = fun_case2(X,FEM)

FEM = CoFE_design(FEM,X,@X_2_FEM);

% Stress constraints
con = zeros(20,1);
allowableStress = 25000;
con(1:10) =   [FEM.CROD.stress].' - allowableStress;
con(11:20) = -[FEM.CROD.stress].' - allowableStress;

% displacement constraints
displacementLimit = 2;
disp = FEM.u(3:6:(4*6));
con(21:24) =   disp - displacementLimit;
con(25:28) = - disp - displacementLimit;

% calculate mass
massDof = 1:6:FEM.ndof; % pick all of one displacement dof
objective = full(sum(sum(FEM.M_G(massDof,massDof))));
