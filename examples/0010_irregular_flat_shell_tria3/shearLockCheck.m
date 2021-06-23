clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

%% Run CoFE for normal and extreme thickness values
cofe001 = Cofe('irregFlatShellTriaT001.dat');
cofe01 = Cofe('irregFlatShellTriaT01.dat');
cofe1 = Cofe('irregFlatShellTriaT1.dat');

%% Compare bending displacement to Nastran
cofeResult = [cofe001.solution(1).displacement.T3(40)
              cofe01.solution(1).displacement.T3(40)
              cofe1.solution(1).displacement.T3(40)];
nastranResult =1.0e+02 *[...
   1.297632220769975
   0.001298079719037
   0.000001318252027];
          
nastranResult./cofeResult    
          
          