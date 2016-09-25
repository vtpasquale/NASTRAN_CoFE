
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'mesh.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 1;
CASE.METHOD = 10;
CASE.STRESS = 1;
CASE.STRAIN = 1;
CASE.ESE = 1;
CASE.PRINT = 0;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post process
CoFE_view(FEM);