
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
% Intput file
inputFile = 'seventyTwoBarTruss.bdf';

% SUBCASE 1
CASE=case_obj;
CASE.SOL = 101; % SOL = 101, SOL = 103, and SOL = 105 are options
CASE.SPC = 1;
CASE.LOAD = 1;
CASE.METHOD = 10;
CASE.STRESS=1;
CASE.STRAIN=1;
CASE.ESE=1;
CASE.EKE=1;

% SUBCASE 2
CASE(2) = CASE(1);
CASE(2).FORCE = 1;
CASE(2).LOAD = 2;

% SUBCASE 3
CASE(3) = CASE(1);
CASE(3).SOL = 103;

% SUBCASE 4
CASE(4) = CASE(1);
CASE(4).SOL = 105;
CASE(4).REF_LC = 1;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Plot results
CoFE_view(FEM);
view(28,20)
axis equal

