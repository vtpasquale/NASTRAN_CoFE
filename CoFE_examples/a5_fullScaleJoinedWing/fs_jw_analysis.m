
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'fullJW.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 1025;
CASE.METHOD = 1;
CASE.STRESS = 1;
CASE.STRAIN = 1;
CASE.ESE = 1;
CASE.EKE = 1;

CASE(2) = CASE(1);
CASE(2).SOL = 103;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post process
CoFE_view(FEM);
view(-45,30)
axis equal