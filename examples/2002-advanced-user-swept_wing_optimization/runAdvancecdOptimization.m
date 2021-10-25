clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));
addpath(fullfile('..','canfield_slp_sqp'))

%% UNCOMMENT ONE OPTION
% gradientFunction = []; % none - complex step sensitivities
gradientFunction = @grdSA; % semi-analytic direct with selective assembly

%% Model
% https://www.ata-plmsoftware.com/resources/on-demand-webinar-design-sensitivity-and-optimization-with-simcenter-nastran-and-femap/
              
%% Process initial-design BDF entries
[cofe,optional] = Cofe('sweptWing.dat',...
                    'getBdfEntries',true,...
                    'presolve',false);

%% Define constant user data here to keep user functions organized
userData.initialBdfEntries = optional.bdfEntries;
userData.initialModel = cofe.model;
userData.dx = 100*eps;

%% SQP options
sqpOptions = optimset('fmincon');
sqpOptions.ComplexStep = 'on';
sqpOptions.DerivativeCheck = 'off';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-3;
sqpOptions.TolFun = 1e-3;

%% Optimize
x = 0.5*ones(26,1);
vlb=0.2*ones(26,1);
vub=[];
tic
[cofeOptimum,opts,v,H,status]=sqp(@fun,x,sqpOptions,vlb,vub,gradientFunction,userData);
runtime = toc

%% Print new input file with optimum design
optimumBdfEntries = design2entries(cofeOptimum,userData.initialBdfEntries);
fid = fopen('sweptWingFinal.dat','w+');
optimumBdfEntries.echo(fid)
fclose(fid);
