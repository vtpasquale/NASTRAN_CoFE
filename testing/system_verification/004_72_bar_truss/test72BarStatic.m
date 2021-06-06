% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','..','cofe_toolbox')));

% Run case
cofe = Cofe(fullfile('nastran_runs','static-000.dat'),'output',false);

% Load Nastran results
nastranNodeOutput = csvread(fullfile('nastran_runs','statics-nodeOutput.csv'),1,1);
nastranElementOutput = csvread(fullfile('nastran_runs','statics-elementOutput.csv'),1,1);

%% Displacement
cofe_displacement_g1 = cofe.solution.displacement_g;
cofe_displacement_g = [cofe_displacement_g1.T1,...
    cofe_displacement_g1.T2,...
    cofe_displacement_g1.T3,...
    cofe_displacement_g1.R1,...
    cofe_displacement_g1.R2,...
    cofe_displacement_g1.R3];

nastran_displacement_g = ...
   [nastranNodeOutput(nastranNodeOutput(:,1)==2,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==3,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==4,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==6,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==7,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==8,3)];

dispDifference = normalizedDifference(cofe_displacement_g,nastran_displacement_g);

assert(all(dispDifference(:)<1e-5),'Displacement vectors do not match verification case.')

%% Constraint Forces
cofeSpcforces1 = cofe.solution.spcforces_g;
cofeSpcforces = [cofeSpcforces1.T1,cofeSpcforces1.T2,cofeSpcforces1.T3,cofeSpcforces1.R1,cofeSpcforces1.R2,cofeSpcforces1.R3];

nastranSpcforces = ...
   [nastranNodeOutput(nastranNodeOutput(:,1)==52,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==53,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==54,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==56,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==57,3),...
    nastranNodeOutput(nastranNodeOutput(:,1)==58,3)];

spcforcesDifference = normalizedDifference(nastranSpcforces,cofeSpcforces);
assert(all(spcforcesDifference(:)<1e-6),'Contraint forces do not match verification case.')

%% Element Forces
nastranForce = ...
   [nastranElementOutput(nastranElementOutput(:,1)==3036,3),...
    nastranElementOutput(nastranElementOutput(:,1)==3038,3)];

% consistent cofe element forces
cofeForce = cell2mat( {cofe.solution.force.values})';

% compare force values
elementForcesDifference = normalizedDifference(nastranForce,cofeForce);
assert(all(elementForcesDifference(:)<1e-6),'Element force values do not match verification case.')

%% Stress
nastranStress = ...
   [nastranElementOutput(nastranElementOutput(:,1)==3183,3),...
    nastranElementOutput(nastranElementOutput(:,1)==3186,3)];

% consistent cofe stress
cofeStress = cell2mat( {cofe.solution.stress.values})';

% Compare stress values, [cofeStress,nastranStress]
stressDifference = normalizedDifference(nastranStress,cofeStress);
assert(all(stressDifference(:)<1e-6),'Stress values do not match verification case.')

%% Strain

%% Element Strain Energy
nastranESE = nastranElementOutput(nastranElementOutput(:,1)==80000,3);

% consistent cofe strain energy
cofeESE = [cofe.solution.strainEnergy.values]';

% Compare strain energy values, [cofeESE;nastranESE]
eseDifference = normalizedDifference(nastranESE,cofeESE);
assert(all(eseDifference(:)<1e-4),'Element strain energy values do not match the verification case.')


