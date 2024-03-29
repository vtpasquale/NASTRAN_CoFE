function [obj,con] = fun2(x,initialBdfEntries)
% Objective function and constraints for optimization
%
% INPUTS
%  x = [nDesignVariables,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% obj = [1,1 double] objective function value
% con = [nConstraints,1 double] constraint function values

bdfEntries = design2entries(x,initialBdfEntries);
cofe = Cofe(bdfEntries);

con = zeros(28,1);
% Stress constraints
allowableStress = 25000;
allStress = [cofe.solution.stress.values];
con(1:10) =   allStress(1,:).' - allowableStress;
con(11:20) = -allStress(1,:).' - allowableStress;

% displacement constraints
displacementLimit = 2;
t3 = cofe.solution.displacement.T3(1:4);
con(21:24) =   t3 - displacementLimit;
con(25:28) = - t3 - displacementLimit;

% Mass objective
obj = sum( [cofe.model.element.mass]);

