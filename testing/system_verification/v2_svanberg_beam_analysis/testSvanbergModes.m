% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','..','cofe_toolbox')));

% Run case
cofe = Cofe(fullfile('nastran_runs','modes.dat'),'output',false);

% Start processing displacements to save isSignInconsistent
nastran_u_g = csvread(fullfile('nastran_runs','modes-u_g.csv'),1,2);
cofe_u_g = cofe.solution.u_g;

nastran_freq = csvread(fullfile('nastran_runs','modesFreq.csv'),1,3);
cofe_freq = cofe.solution.eigenvalueTable.frequency;

isDistinct = findDistinctArrayEntries(cofe_freq,1e-6);
scalingMatrix = nastran_u_g\cofe_u_g;

%% Frequencies
freqDifference = normalizedDifference(nastran_freq,cofe_freq);
assert(all(freqDifference<1e-6),'Natural frequencies don''t match the verification case.')

%% Check modes scaling matrix
distinctModesScalingMatrix = scalingMatrix(isDistinct,isDistinct);
assert(all(abs( abs(diag(distinctModesScalingMatrix))-1 ) < 1e-5),...
    ['Diagonal terms of the scaling matrix should be +/- 1 for distinct modes.',...
     'Check eigenvector scaling options for the verifcation data (select mass normalization).'])

assert(all(all(abs(distinctModesScalingMatrix - diag(diag(distinctModesScalingMatrix))) < 1e-5)),...
    'Off diagonal terms of the scaling matrix should be 0 for distinct modes.')

assert(all(all(abs(scalingMatrix(isDistinct,~isDistinct)) < 1e-6 )),...
    'There is coupling between distinct and nondistict modes. Verification fail.')

%% Displacments
dispDifference = normalizedDifference(nastran_u_g*scalingMatrix,cofe_u_g);
assert(all(dispDifference(:)<1e-4),'Displacement vectors do not match verification case.')

%% Constraint Forces
nastranSpcforces = csvread(fullfile('nastran_runs','modesSpcforces.csv'),1,2);
cofeSpcforces1 = cofe.solution.spcforces_g;
cofeSpcforces = [cofeSpcforces1.T1;cofeSpcforces1.T2;cofeSpcforces1.T3;cofeSpcforces1.R1;cofeSpcforces1.R2;cofeSpcforces1.R3];
spcforcesDifference = normalizedDifference(nastranSpcforces*scalingMatrix,cofeSpcforces);
assert(all(spcforcesDifference(:)<1e-4),'Contraint forces do not match verification case.')

%% Element Forces
nastranForce0 = csvread(fullfile('nastran_runs','modesForce.csv'),0,1);

% reoder nastran output quantities consistently
reorder0 = [9 5 6 11 2 1 10 7 8 12 4 3]';
reorder = reorder0;
for i = 2:5
    reorder = [reorder;reorder0+(i-1)*12];
end
nastranForce = nastranForce0(reorder,3:end);

% Reverse Nastran My direction, Nastran uses an abnormal sign convention for My
nastranForce(5:6:end,:) = -nastranForce(5:6:end,:);

% consistent cofe element forces
cofeForce = cell2mat( {cofe.solution.force.values}' );

% compare force values
elementForcesDifference = normalizedDifference(nastranForce*scalingMatrix,cofeForce);
assert(all(elementForcesDifference(:)<2e-4),'Element force values do not match verification case.')

%% Stress
nastranStress = csvread(fullfile('nastran_runs','modesStress.csv'),1,3);

% consistent cofe stress
cofeStress = cell2mat( {cofe.solution.stress.values}' );

% Compare stress values, [cofeStress,nastranStress]
stressDifference = normalizedDifference(nastranStress*scalingMatrix,cofeStress);
assert(all(stressDifference(:)<2e-4),'Stress values do not match verification case.')

%% Strain
nastranStrain = csvread(fullfile('nastran_runs','modesStrain.csv'),1,3);

% consistent cofe strain
cofeStrain = cell2mat( {cofe.solution.strain.values}' );

% Compare strain values, [cofeStrain,nastranStrain]
straisDifference = normalizedDifference(nastranStrain*scalingMatrix,cofeStrain);
assert(all(straisDifference(:)<2e-4),'Stress values do not match verification case.')

%% Element Strain Energy
nastranESE = csvread(fullfile('nastran_runs','modesESE.csv'),1,3);

% consistent cofe strain energy
cofeESE = cell2mat({cofe.solution.strainEnergy.values}');

% Compare strain energy values, [cofeESE;nastranESE]
eseDifference = normalizedDifference(nastranESE,cofeESE);
assert(all(eseDifference(:)<1e-5),'Element strain energy values do not match the verification case.')


