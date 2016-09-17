
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
% input file
inputFile = 'seventyTwoBarTruss.bdf';

% SUBCASE 1
CASE=case_obj;
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 1;
CASE.STRESS=1;

% SUBCASE 2
CASE(2) = CASE(1);
CASE(2).LOAD = 2;

%% Initialize model
FEM0 = CoFE_design_initialize(inputFile,CASE);

%% SQP options
sqpOptions = optimset('fmincon');
% sqpOptions.ComplexStep = 'on';
% sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-7;
sqpOptions.TolFun = 1e-7;

% turn off active set warning
warning('off','optim:quadprog:WillBeRemoved')

%% Optimize
X=0.5*ones(16,1);
vlb=.1*ones(16,1);
vub=[];

[x,opts,v,H,status]=optimization.sqp(@fun,X,sqpOptions,vlb,vub,@grd,FEM0);

%% Report
fprintf('Design from CoFE + SQP \n');
for i = 1:length(x); fprintf('\t x_%d = %.4g \n',i,x(i)); end

%% Create new bulk data input file
FEM = CoFE_design(FEM0,x,@X_2_FEM);
FEM(1).echo('seventyTwoBarTruss_final.bdf');