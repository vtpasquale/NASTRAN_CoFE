
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
CASE.inputFile = 'topex3a.dat';
CASE.SOL = 101;
CASE.SPC = 2;
CASE.LOAD = 2;
CASE.METHOD = 10;
CASE.RECOVER = 0;
CASE.WRITE_c06 = 0;

%% Run CoFE
FEM = CoFE_analysis(CASE);

%% Post
post_gui(FEM)
axis equal