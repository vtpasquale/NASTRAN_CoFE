
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
CASE.inputFile = 'seventyTwoBarTruss.bdf';
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 1;

%% Initialize model
FEM = CoFE_design_initialize(CASE);

%% SQP options
sqpOptions = optimset('fmincon');
% sqpOptions.ComplexStep = 'on';
% sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-7;
sqpOptions.TolFun = 1e-7;
% sqpOptions.MaxFunEvals = 10;

% turn off active set warning
warning('off','optim:quadprog:WillBeRemoved')

%% Optimize
X=0.5*ones(16,1);
vlb=.1*ones(16,1);
vub=[];

[x,opts,v,H,status]=optimization.sqp(@fun,X,sqpOptions,vlb,vub,@grd,FEM);

%% Report
fprintf('Design from CoFE + SQP \n');
for i = 1:length(x); fprintf('\t x_%d = %.4g \n',i,x(i)); end

%% Create new bulk data input file
FEM = CoFE_design(FEM,x,@X_2_FEM);
FEM.echo('seventyTwoBarTruss_final.bdf');