
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% Auxiliary CASE data
auxInputFile = 'd200cs_aux.bdf';
AUXCASE = case_obj;
AUXCASE.SOL = 101;
AUXCASE.SPC = 25;
AUXCASE.LOAD = 100;
AUXCASE.STRESS = 1;
AUXCASE.STRAIN = 1;
AUXCASE.ESE = 1;
AUXCASE.PRINT = 0;

AUXCASE(2) = AUXCASE(1); AUXCASE(2).LOAD = 101;
AUXCASE(3) = AUXCASE(1); AUXCASE(3).LOAD = 102;
AUXCASE(4) = AUXCASE(1); AUXCASE(4).LOAD = 103;
AUXCASE(5) = AUXCASE(1); AUXCASE(5).LOAD = 104;
AUXCASE(6) = AUXCASE(1); AUXCASE(6).LOAD = 105;
AUXCASE(7) = AUXCASE(1); AUXCASE(7).LOAD = 106;

%% Run Auxiliary Cases in CoFE to Determine Basis Vectors
FEM_aux = CoFE_analysis(auxInputFile,AUXCASE);

%% Scale Basis Vectors to Unit Maximum Displacement
gind = [];
for n = 1:40;
    gind = [gind,(1:3)+(n-1)*6];
    nind(n,:) = (1:3)+(n-1)*3;
end
unscaledBV = [FEM_aux.u];
unscaledBV = unscaledBV(gind,:);
BV = unscaledBV .* repmat(1./max(abs(unscaledBV)),[size(unscaledBV,1),1]);

%% Optimization CASE data
inputFile = 'd200cs.bdf';
CASE=case_obj;
CASE.SOL = 101;
CASE.SPC = 25;
CASE.LOAD = 1;
CASE.STRESS=1;

%% Initialize model
FEM0 = CoFE_design_initialize(inputFile,CASE);

%% Save design data for X_2_FEM.m function
FEM0.designData.BV = BV;
FEM0.designData.nind = nind;
FEM0.designData.GRID = FEM0.GRID;

%% SQP options
sqpOptions = optimset('fmincon');
sqpOptions.ComplexStep = 'on';
sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-4;
sqpOptions.TolFun = 1e-4;

% turn off active set warning
warning('off','optim:quadprog:WillBeRemoved')

%% Optimize
X=zeros(7,1);
vlb=-1.e6*ones(7,1);
vub=1.e6*ones(7,1);

[x,opts,v,H,status]=optimization.sqp(@fun,X,sqpOptions,vlb,vub,@grd,FEM0);

%% Report
fprintf('Design from CoFE + SQP \n');
for i = 1:length(x); fprintf('\t x_%d = %.4g \n',i,x(i)); end

%% Create new bulk data input file
FEM = CoFE_design(FEM0,x,@X_2_FEM);
FEM(1).echo('d200cs_final.bdf');

%% Show Results with New Design
finalInputFile = 'd200cs_final.bdf';
FinalCASE = case_obj;
FinalCASE.SOL = 101;
FinalCASE.SPC = 25;
FinalCASE.LOAD = 1;
FinalCASE.STRESS = 1;
FinalCASE.STRAIN = 1;
FinalCASE.ESE = 1;
FinalCASE.PRINT = 0;
FinalFEM = CoFE_analysis(finalInputFile,FinalCASE);
CoFE_view(FinalFEM);
axis equal
