
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
CASE.inputFile = 'tenBar_initial.bdf';
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 88;
CASE.METHOD = 30;

%% Initialize model
FEM = CoFE_design_initialize(CASE);

%% SQP options
sqpOptions = optimset('fmincon');
% sqpOptions.ComplexStep = 'on';
% sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-11;
sqpOptions.TolFun = 1e-11;

% turn off active set warning
warning('off','optim:quadprog:WillBeRemoved')

%% Optimize
X0 = 3.0*ones(10,1);
vlb=  .1*ones(10,1);
vub= 100*ones(10,1);

[x,opts,v,H,status]=optimization.sqp(@fun_case1,X0,sqpOptions,vlb,vub,@grd_case1,FEM);

%% Report design
fprintf('Design from CoFE + SQP \n');
for i = 1:length(x); fprintf('\t x_%d = %.4g \n',i,x(i)); end

%% Create new bulk data input file
FEM = CoFE_design(FEM,x,@X_2_FEM);
FEM.echo('tenBar_final.bdf');
