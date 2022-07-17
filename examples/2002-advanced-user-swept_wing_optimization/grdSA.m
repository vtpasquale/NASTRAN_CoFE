function [obj,con] = grdSA(x,userData)
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

% Update initial Model object based on design variable values.
model = design2model(x,userData.initialModel);

% Run analysis
cofe = Cofe(model,'skip','preprocess','stopBefore','solve');
analysis = cofe.model.reducedModel;

% Sensitivity system assembly with complex perturbations
index2Pid = [102:109,201:209,301:309];
for i = 1:nX
    xComplexStep = x;
    xComplexStep(i)    = xComplexStep(i) + 1i*userData.dx;

    % save assembly time by operating directly on the model rather than on the entries
    cofeComplex(i).model = design2model(xComplexStep,cofe.model);
    
    % selective assembly
    selectPid = index2Pid(i);
    cofeComplex(i).model = seletiveAssembleProperties(cofeComplex(i).model,cofe.model,selectPid);
end

% Calculate dudx using semi-analytic approach
nA = size(analysis.u_a,1); % A set size
dudxLoadCase1 = zeros(nA,nX);
analysis = analysis.factorizeStiffness();
for i = 1:nX
    % calculate direct pseudo load vectors (df_a/dx-dK_aa/dx*u_a) for all
    % load cases at once
    pseudoLoads = cofeComplex(i).model.reducedModel.calculateDirectSensitivityPseudoLoad(analysis.u_a,userData.dx);

    % calculate dudx for all load cases at once
    % dudx = analysis.K_aa\pseudoLoads;
    dudx = analysis.forwardaAndBackSubstitution(pseudoLoads);
    
    % % % check against complex-step dudx
    % % dudx_imag=cofeComplex(i).model.reducedModel.solveUaAllLoadSets()
    % % dudx_cs = imag(dudx_imag.u_a)./userData.dx;
    % % [dudx(:,1),dudx_cs(:,1)]

    % seperate load cases vectors
    dudxLoadCase1(:,i) = dudx(:,1);
end

% Create u_a vector with complex perturbations for response sensitivity
% calculation with complex step
uBarLoadCase1 = analysis.u_a(:,1) + (1i*userData.dx)* dudxLoadCase1;

% Instantiate StaticSolution objects to store sensitivity data
for i = 1:nX
    drdx(i,1) = StaticsSolution;
    drdx(i,1).loadCaseIndex = 1;
    drdx(i,1).caseControlIndex = 1;
end

% Recover sensitivity results -> vectorized across load cases
for i = 1:nX
    uBar = uBarLoadCase1(:,i);
    drdx(i,1) = cofeComplex(i).model.recover(drdx(i,1),uBar);
end

% Stress constraints
con = zeros(8064,nX);
allowableStress = 30000;
for i = 1:nX
    allStress = imag([drdx(i).stress.values])./userData.dx;
    vmStress = [allStress(8,:),allStress(16,:)].';
    con(:,i) = vmStress./allowableStress;
end

% Mass objective
obj = zeros(nX,1);
for i = 1:nX
    obj(i) = imag( sum( [cofeComplex(i).model.element.mass]) )./userData.dx;
end

% Transpose constraints
con = con.';