clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));
addpath(fullfile('..','canfield_slp_sqp'))

%% Process initial-design BDF entries
[~,optional] = Cofe('tenBar.dat',...
                    'getBdfEntries',true,...
                    'stopBefore','preprocess');
initialBdfEntries = optional.bdfEntries;

%% SQP options
sqpOptions = optimset('fmincon');
sqpOptions.ComplexStep = 'on';
sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-5;
sqpOptions.TolFun = 1e-5;
sqpOptions.MaxFunEvals = 2000;

%% Optimize
x =   [10.0*ones(10,1);zeros(4,1)];
vlb=  [.1*ones(10,1);-999*ones(4,1)];
vub=  [100*ones(10,1); 999*ones(4,1)];
[cofeOptimum,opts,v,H,status]=sqp(@fun,x,sqpOptions,vlb,vub,[],initialBdfEntries);

%% Print new input file with optimum design
optimumBdfEntries = design2entries(cofeOptimum,initialBdfEntries);
fid = fopen('tenBarShapeOptimum.dat','w+');
optimumBdfEntries.echo(fid)
fclose(fid);


