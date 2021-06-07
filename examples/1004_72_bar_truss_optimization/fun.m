function [obj,con] = fun(x,initialBdfEntries)
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
con = zeros(176,1);
allowableStress = 25000;
allStress = [ [cofe.solution(1).stress.values],[cofe.solution(2).stress.values]];
con(1:288)  = [ allStress(1,:).' - allowableStress;
               -allStress(1,:).' - allowableStress];

% Displacement constraints
maxDef = 0.25;
% cofe.solution(1).displacement.ID(1:4)
displacements = [cofe.solution(1).displacement.T1(1:4);
                 cofe.solution(1).displacement.T2(1:4);
                 cofe.solution(2).displacement.T1(1:4);
                 cofe.solution(2).displacement.T2(1:4)];
con(289:320) = [ displacements - maxDef;
                -displacements - maxDef];

% Mass objective
obj = sum( [cofe.model.element.mass]);