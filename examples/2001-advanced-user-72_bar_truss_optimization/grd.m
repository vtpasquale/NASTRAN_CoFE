function [obj,con] = grd(x,userData)
% Derivatives of objective function and constraints for optimization
%
% INPUTS
%  x = [nDesignVariables,1 double] vector of design variable values.
%  initialBdfEntries = [BdfEntries] Initial BdfEntries object to be updated based on design variable values.
%
% OUTPUTS
% obj = [1,1 double] objective function value
% con = [nConstraints,1 double] constraint function values
nX = size(x,1);

% Update initial BdfEntries object based on design variable values.
bdfEntries = design2entries(x,userData.initialBdfEntries);

% Run analysis
cofe = Cofe(bdfEntries,'solve',false);
analysis = cofe.model.reducedModel;

% Sensitivity system assembly with complex perturbations
for i = 1:nX
    xComplexStep = x;
    xComplexStep(i)    = xComplexStep(i) + 1i*userData.dx;
    bdfEntriesComplexI = design2entries(xComplexStep,userData.initialBdfEntries);
    cofeComplex(i)     = Cofe(bdfEntriesComplexI,'presolve',false);
end

% Calculate dudx using semi-analytic approach
nA = size(analysis.u_a,1); % A set size
dudxLoadCase1 = zeros(nA,nX);
dudxLoadCase2 = zeros(nA,nX);
for i = 1:nX
    % calculate direct pseudo load vectors (df_a/dx-dK_aa/dx*u_a) for all
    % load cases at once
    pseudoLoads = cofeComplex(i).model.reducedModel.calculateDirectSensitivityPseudoLoad(analysis.u_a,userData.dx);

    % calculate dudx for all load cases at once
    dudx = analysis.K_aa\pseudoLoads;
    
    % % % check against complex-step dudx
    % % dudx_imag=cofeComplex(i).model.reducedModel.solveUaAllLoadSets()
    % % dudx_cs = imag(dudx_imag.u_a)./userData.dx;
    % % [dudx(:,1),dudx_cs(:,1)]

    % seperate load cases vectors
    dudxLoadCase1(:,i) = dudx(:,1);
    dudxLoadCase2(:,i) = dudx(:,2); 
end

% Create u_a vector with complex perturbations for response sensitivity
% calculation with complex step
uBarLoadCase1 = analysis.u_a(:,1) + (1i*userData.dx)* dudxLoadCase1;
uBarLoadCase2 = analysis.u_a(:,2) + (1i*userData.dx)* dudxLoadCase2;

% Instantiate StaticSolution objects to store sensitivity data
for i = 1:nX
    drdx(i,1) = StaticsSolution;
    drdx(i,1).loadCaseIndex = 1:2;
    drdx(i,1).caseControlIndex = 1;
end

% Recover sensitivity results -> vectorized across load cases
for i = 1:nX
    uBar = [uBarLoadCase1(:,i),uBarLoadCase2(:,i)];
    drdx(i,1) = cofeComplex(i).model.recover(drdx(i,1),uBar);
end

% Stress constraints
con = zeros(320,nX);
for i = 1:nX
    allStress = imag( [drdx(i).stress.values] )./userData.dx;
    stressLoadCase1 = allStress(1,1:2:end);
    stressLoadCase2 = allStress(1,2:2:end);
    con(1:288,i)  = [ stressLoadCase1.';
                      stressLoadCase2.';
                     -stressLoadCase1.';
                     -stressLoadCase2.'];
end

% Displacement constraints
for i = 1:nX
    displacements = imag(...
                    [drdx(i).displacement.T1(1:4,1);
                     drdx(i).displacement.T2(1:4,1);
                     drdx(i).displacement.T1(1:4,2);
                     drdx(i).displacement.T2(1:4,2)])./userData.dx;
    con(289:320,i) = [ displacements;
                      -displacements];
end

% Mass objective
obj = zeros(16,1);
for i = 1:nX
    obj(i) = imag( sum( [cofeComplex(i).model.element.mass]) )./userData.dx;
end

% Transpose constraints
con = con.';