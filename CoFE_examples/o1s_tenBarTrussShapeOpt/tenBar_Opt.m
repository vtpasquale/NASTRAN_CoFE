
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
sqpOptions.TolCon = 1e-5;
sqpOptions.TolFun = 1e-5;
% sqpOptions.MaxIter = 10000;
% sqpOptions.MaxFunEvals = 10000;

% turn off active set warning
warning('off','optim:quadprog:WillBeRemoved')

%% Optimize
X0 = [10.0*ones(10,1);zeros(4,1)];
vlb=[ .1*ones(10,1);-999*ones(4,1)];
vub=[100*ones(10,1); 999*ones(4,1)];

[x,opts,v,H,status]=optimization.sqp(@fun,X0,sqpOptions,vlb,vub,@grd,FEM);

%% Report design
fprintf('Design from CoFE + SQP \n');
for i = 1:length(x); fprintf('\t x_%d = %.4g \n',i,x(i)); end

%% Create new bulk data input file
FEM = CoFE_design(FEM,x,@X_2_FEM);
FEM.echo('tenBar_final.bdf');

%% Plot Mesh
% initial design
FEM0 = CoFE_design(FEM,X0,@X_2_FEM);
figure(1)
post.plotMesh(FEM0)
view(0,0)
axis equal
axis([-10 750 -10 10 -375 10])
title('Initial Design')

figure(2)
post.plotMesh(FEM,[],[],[],[],2)
view(0,0)
axis equal
axis([-10 750 -10 10 -375 10])
title('Final Design')
