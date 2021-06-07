function [obj,con] = fun1(x,initialBdfEntries)
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

% Stress constraints
con = zeros(20,1);
allowableStress = 25000;

allStress = [cofe.solution.stress.values];
con(1:10) =   allStress(1,:).' - allowableStress;
con(11:20) = -allStress(1,:).' - allowableStress;

% Mass objective
obj = sum( [cofe.model.element.mass]);

