% Objective function, constrants, and derivatives for optimization
%
function [obj_prime,con_prime] = grd(X,FEM)

[~,FEM_prime] = CoFE_design(FEM,X,@X_2_FEM);

t = 0.062/21.483152759999999;  

cp = [FEM_prime.u];
con_prime = -cp(33,:)';
obj_prime = 4*t*ones(1,5)';
