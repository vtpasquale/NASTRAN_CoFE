% Objective function, constrants, and derivatives for optimization
%
function [obj,con] = fun(X,FEM)

FEM = CoFE_design(FEM,X,@X_2_FEM);

t = 0.062/21.483152759999999;  
tipDef = -5.0^3*1.0E8/(250*1440.E6*t);

obj = t*4*sum(X);
con = tipDef-FEM.x(33);