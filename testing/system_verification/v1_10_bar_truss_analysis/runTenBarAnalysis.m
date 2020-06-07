clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));

%%
% cofe = Cofe('tenBarAnalysis.dat','output',false);
% cofe.solution(1).displacement.printTextOutput(1)

cofe = Cofe('tenBarAnalysis.dat');
