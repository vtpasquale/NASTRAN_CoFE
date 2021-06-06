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

% Stress constraints
con = zeros(20,1);
allowableStress = 25000;

allStress = [cofe.solution.stress.values];
con(1:10) =   allStress(1,:).' - allowableStress;
con(11:20) = -allStress(1,:).' - allowableStress;

% Mass objective
obj = sum( [cofe.model.element.mass]);

