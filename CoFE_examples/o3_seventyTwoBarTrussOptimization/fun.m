% Objective function, constrants, and derivatives for optimization
%
function [objective,con] = fun(X,FEM)

%% Analysis
FEM = CoFE_design(FEM,X,@X_2_FEM);

%% stress constraints
allowableStress = 25000;
con = zeros(320,1);

FEM1s1 = [FEM(1).CROD.stress].';
FEM2s1 = [FEM(2).CROD.stress].';

con(1:288) =  [
 FEM1s1 - allowableStress;
-FEM1s1 - allowableStress;
 FEM2s1 - allowableStress;
-FEM2s1 - allowableStress];

%% Displacement constraints
maxDef = 0.25;
con(289:320) = [
  FEM(1).u([1:2,7:8,13:14,19:20]) - maxDef;
 -FEM(1).u([1:2,7:8,13:14,19:20]) - maxDef;
  FEM(2).u([1:2,7:8,13:14,19:20]) - maxDef;
 -FEM(2).u([1:2,7:8,13:14,19:20]) - maxDef];

%% Objective
% calculate mass
massDof = 1:6:FEM(1).ndof; % pick all of one displacement dof
objective = full(sum(sum(FEM(1).M_G(massDof,massDof))));