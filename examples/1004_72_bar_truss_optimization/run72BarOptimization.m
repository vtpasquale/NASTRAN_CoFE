clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));
addpath(fullfile('..','canfield_slp_sqp'))

%% Model and published result
% The seventy two bar space truss was developed for:
% Fox, Richard L., and Lucien A. Schmit, JR. "Advances in the Integrated 
% Approach to Structural Synthesis." Journal of Spacecraft and Rockets 3.6 
% (1966): 858-866.
% 
% The design problem is described in:
% Haftka, Raphael T. Elements of Structural Optimization. Vol. 11. Springer
% ,1992. Pages 238, 244. However, there are typos in Haftka's problem 
% description that are detrimental to the benchmark results.
% 
% The problem is described without typos in:
% Sedaghati, R. "Benchmark Case Studies in Structural Design Optimization
% Using the Force Method." International Journal of Solids and Structures 
% 42.21 (2005): 5848-5871.
sedaghatiOptimum = [0.1565; 0.5456; 0.4104; 0.5697; 0.5237; 0.5171; 0.1;...
                    0.1; 1.268; 0.5117; 0.1; 0.1; 1.886; 0.5123; 0.1; 0.1]; 

%% Process initial-design BDF entries
[~,optional] = Cofe('seventyTwoBarTruss.dat',...
                    'getBdfEntries',true,...
                    'stopAfterEntries',true);
initialBdfEntries = optional.bdfEntries;

%% SQP options
sqpOptions = optimset('fmincon');
sqpOptions.ComplexStep = 'on';
sqpOptions.DerivativeCheck = 'on';
sqpOptions.Display = 'on';
sqpOptions.Termination = -1; 
sqpOptions.TolCon = 1e-6;
sqpOptions.TolFun = 1e-6;

%% Optimize
x = 0.5*ones(16,1);
vlb=.1*ones(16,1);
vub=[];
[cofeOptimum,opts,v,H,status]=sqp(@fun,x,sqpOptions,vlb,vub,[],initialBdfEntries);

%% Print new input file with optimum design
optimumBdfEntries = design2entries(cofeOptimum,initialBdfEntries);
fid = fopen('seventyTwoBarOptimum.dat','w+');
optimumBdfEntries.echo(fid)
fclose(fid);

%% Compare result to Sedaghati
table(sedaghatiOptimum,cofeOptimum)
