% Objective function, constrants, and derivatives for optimization
%
function [objective,con] = grd(X,FEM)

%% Analysis
[FEM,FEM_prime] = CoFE_design(FEM,X,@X_2_FEM);

%% stress constraints
con = zeros(320,16);
for i = 1:16
    FEM1s1 = [FEM_prime(i,1).CROD.stress].';
    FEM2s1 = [FEM_prime(i,2).CROD.stress].';  
    con(1:288,i) =  [
         FEM1s1;
        -FEM1s1;
         FEM2s1;
        -FEM2s1];
end

%% Displacement constraints
for i = 1:16
con(289:320,i) =  [
  FEM_prime(i,1).u([1:2,7:8,13:14,19:20]);
 -FEM_prime(i,1).u([1:2,7:8,13:14,19:20]);
  FEM_prime(i,2).u([1:2,7:8,13:14,19:20]);
 -FEM_prime(i,2).u([1:2,7:8,13:14,19:20])];
end

%% Objective
% calculate mass
objective = zeros(16,1);
massDof = 1:6:FEM(1).ndof; % pick all of one displacement dof
for i = 1:16
    objective(i) = d(full(sum(sum(FEM_prime(i,1).M_G(massDof,massDof)))));
end

%% transpose con
con = con.';