
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'topex3a_bliq.dat';
CASE=case_obj;
CASE.SOL = 101; % SOL = 101, SOL = 103, and SOL = 105 are options
CASE.SPC = 2;
CASE.LOAD = 2;
CASE.METHOD = 10;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post
CoFE_view(FEM)
axis equal