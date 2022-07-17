function [obj,con] = fun(x,userData)
% Objective function and constraints for optimization
%
% INPUTS
%  x = [nDesignVariables,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% obj = [1,1 double] objective function value
% con = [nConstraints,1 double] constraint function values

% Update initial Model object based on design variable values.
model = design2model(x,userData.initialModel);

% Run analysis
cofe = Cofe(model,'skip','preprocess');

% stress constraints
allStress = [cofe.solution.stress.values];
vmStress = [allStress(8,:),allStress(16,:)].';
allowableStress = 30000;
con = vmStress./allowableStress - 1;

% Mass objective
obj = sum( [cofe.model.element.mass]);