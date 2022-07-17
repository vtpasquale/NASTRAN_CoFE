clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));
addpath(fullfile('..','canfield_slp_sqp'))

%% Model and published result
% Model development:
% Venkayya, V. B. (1971). "Design of Optimum Structures," Computers & 
% Structures, 1(1), 265-309.
%
% Optimization case and result:
% Haftka, Raphael T. Elements of Structural Optimization. Springer, 1992. 
% Pages 238, 244.
haftkaOptimum = [30.52; 0.1; 23.20; 15.22; 0.1; 0.55; 7.46; 21.04; 21.53; 0.1]; 

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
sqpOptions.TolCon = 1e-9;
sqpOptions.TolFun = 1e-9;

%% Optimize
x = 10.0*ones(10,1);
vlb=  .1*ones(10,1);
vub= 100*ones(10,1);
[cofeOptimum,opts,v,H,status]=sqp(@fun2,x,sqpOptions,vlb,vub,[],initialBdfEntries);

%% Print new input file with optimum design
optimumBdfEntries = design2entries(cofeOptimum,initialBdfEntries);
fid = fopen('tenBarOptimum2.dat','w+');
optimumBdfEntries.echo(fid)
fclose(fid);

%% Compare result to Haftka
table(haftkaOptimum,cofeOptimum)
