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
haftkaOptimum = [7.94; 0.1; 8.06; 3.94; 0.1; 0.1; 5.74; 5.57; 5.57; 0.1]; 

%% Process initial-design BDF entries
[~,optional] = Cofe('tenBar.dat',...
                    'getBdfEntries',true,...
                    'stopAfterEntries',true);
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
x = 3.0*ones(10,1);
vlb=  .1*ones(10,1);
vub= 100*ones(10,1);
[cofeOptimum,opts,v,H,status]=sqp(@fun1,x,sqpOptions,vlb,vub,[],initialBdfEntries);

%% Print new input file with optimum design
optimumBdfEntries = design2entries(cofeOptimum,initialBdfEntries);
fid = fopen('tenBarOptimum1.dat','w+');
optimumBdfEntries.echo(fid)
fclose(fid);

%% Compare result to Haftka
table(haftkaOptimum,cofeOptimum)
