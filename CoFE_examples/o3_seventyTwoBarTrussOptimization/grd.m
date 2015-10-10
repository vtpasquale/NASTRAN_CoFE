% Objective function, constrants, and derivatives for optimization
%
function [objective,con] = grd(X,FEM)

%% Analysis
FEM.CASE.LOAD = 1;
[FEM1,FEM1_prime] = CoFE_design(FEM,X,@X_2_FEM);

FEM.CASE.LOAD = 2;
[~,FEM2_prime] = CoFE_design(FEM,X,@X_2_FEM);

%% stress constraints
con = zeros(320,16);
for i = 1:16
con(1:288,i) =  [
 [FEM1_prime(i).CROD.stress].'
-[FEM1_prime(i).CROD.stress].'
 [FEM2_prime(i).CROD.stress].'
-[FEM2_prime(i).CROD.stress].'];
end

%% Displacement constraints
for i = 1:16
con(289:320,i) =  [
  FEM1_prime(i).x([1:2,7:8,13:14,19:20]);
 -FEM1_prime(i).x([1:2,7:8,13:14,19:20]);
  FEM2_prime(i).x([1:2,7:8,13:14,19:20]);
 -FEM2_prime(i).x([1:2,7:8,13:14,19:20])];
end

%% Objective
% calculate mass
objective = zeros(16,1);
massDof = 1:6:FEM1.ndof; % pick all of one displacement dof
for i = 1:16
    objective(i) = d(full(sum(sum(FEM1_prime(i).M_G(massDof,massDof)))));
end

%% transpose con
con = con.';