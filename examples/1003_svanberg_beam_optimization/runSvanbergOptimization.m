clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));
addpath(fullfile('..','canfield_slp_sqp'))

%% Model and published result
% Svanberg, Krister. "The Method of Moving Asymptotes-A New Method for 
% Structural Optimization." International Journal for Numerical Methods in 
% Engineering 24.2 (1987): 359-373.
svanbergOptimum = [6.016; 5.309; 4.494; 3.502; 2.153]; 

%% Process initial-design BDF entries
[~,optional] = Cofe('svanberg.dat',...
                    'getBdfEntries',true,...
                    'stopBefore','preprocess');
initialBdfEntries = optional.bdfEntries;

%% SQP options
sqpOptions = optimset('fmincon');
sqpOptions.ComplexStep = 'on';
sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-9;
sqpOptions.TolFun = 1e-9;

%% Optimize
x=5*ones(5,1);
vlb=.01*ones(5,1);
vub=100*ones(5,1);
[cofeOptimum,opts,v,H,status]=sqp(@fun,x,sqpOptions,vlb,vub,[],initialBdfEntries);

%% Print new input file with optimum design
optimumBdfEntries = design2entries(cofeOptimum,initialBdfEntries);
fid = fopen('svanbergOptimum.dat','w+');
optimumBdfEntries.echo(fid)
fclose(fid);

%% Compare result to Svanberg
table(svanbergOptimum,cofeOptimum)

