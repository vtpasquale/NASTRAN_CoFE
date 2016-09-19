
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'svanberg.bdf';
CASE = case_obj; % type "doc case_obj" for class details

% subcase 1
CASE.SOL = 101; % Solution Type
CASE.SPC = 1; % Single Point Constraint ID
CASE.LOAD = 1; % LOAD case ID
CASE.METHOD = 30; % EIGRL ID
CASE.STRESS = 1; % request stress output
CASE.STRAIN = 1; % request strain output
CASE.EKE = 1; % request element kinetic energy output
CASE.ESE = 1; % request element strain energy output

% subcase 2
CASE(2) = CASE(1);
CASE(2).SOL = 103;

% subcase 3
CASE(3) = CASE(1);
CASE(3).SOL = 105;
CASE(3).REF_LC = 1; % Subcase index of static reference solution for buckling analysis 

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post process
CoFE_view(FEM);
view(0,0)
axis equal