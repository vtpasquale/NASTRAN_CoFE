
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'topex3a.dat';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 2;
CASE.LOAD = 2;
CASE.METHOD = 10;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post process
CoFE_view(FEM);
axis equal