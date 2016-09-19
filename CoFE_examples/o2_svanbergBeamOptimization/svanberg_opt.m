
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'svanberg.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 1;

%% Initialize model
FEM = CoFE_design_initialize(inputFile,CASE);

%% SQP options
sqpOptions = optimset('fmincon');
% sqpOptions.ComplexStep = 'on';
% sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-9;
sqpOptions.TolFun = 1e-9;

% turn off active set warning
warning('off','optim:quadprog:WillBeRemoved')

%% Optimize
X=5*ones(5,1);
vlb=.01*ones(5,1);
vub=100*ones(5,1);
[x,opts,v,H,status]=optimization.sqp(@fun,X,sqpOptions,vlb,vub,@grd,FEM);

%% Report
fprintf('Design from CoFE + SQP \n');
for i = 1:5; fprintf('\t x_%d = %g \n',i,x(i)); end

%% Create new bulk data input file
FEM = CoFE_design(FEM,x,@X_2_FEM);
FEM.echo('svanberg_final.bdf');
