function [obj,con] = fun(x,initialBdfEntries)
% Objective function and constrants for optimization
%
% INPUTS
%  x = [n,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% obj = [double] objective function value
% con = [double] constraint function value

bdfEntries = design2entries(x,initialBdfEntries);
cofe = Cofe(bdfEntries);


t = 0.062/21.483152759999999;  
tipDef = -5.0^3*1.0E8/(250*1440.E6*t);

obj = t*4*sum(x);
con = tipDef-cofe.solution.displacement.T3(end);