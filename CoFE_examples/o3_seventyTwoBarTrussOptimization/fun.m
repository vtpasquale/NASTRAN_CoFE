% Objective function, constrants, and derivatives for optimization
%
function [objective,con] = fun(X,FEM)

%% Analysis
FEM.CASE.LOAD = 1;
FEM1 = CoFE_design(FEM,X,@X_2_FEM);
                                      
FEM.CASE.LOAD = 2;
FEM2 = CoFE_design(FEM,X,@X_2_FEM);

%% stress constraints
allowableStress = 25000;
con = zeros(320,1);
con(1:288) =  [
 [FEM1.CROD.stress].' - allowableStress;
-[FEM1.CROD.stress].' - allowableStress;
 [FEM2.CROD.stress].' - allowableStress;
-[FEM2.CROD.stress].' - allowableStress];

%% Displacement constraints
maxDef = 0.25;
con(289:320) = [
  FEM1.x([1:2,7:8,13:14,19:20]) - maxDef;
 -FEM1.x([1:2,7:8,13:14,19:20]) - maxDef;
  FEM2.x([1:2,7:8,13:14,19:20]) - maxDef;
 -FEM2.x([1:2,7:8,13:14,19:20]) - maxDef];

%% Objective
% calculate mass
massDof = 1:6:FEM1.ndof; % pick all of one displacement dof
objective = full(sum(sum(FEM1.M_G(massDof,massDof))));