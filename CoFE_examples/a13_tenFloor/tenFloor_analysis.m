
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
CASE.inputFile = 'tenFloor.bdf';
CASE.SOL = 103; % SOL = 101, SOL = 103, and SOL = 105 are options
CASE.SPC = 10;
CASE.LOAD = 88;
CASE.METHOD = 30;

%% Run CoFE
FEM = CoFE_analysis(CASE);

%% Plot results
post_gui(FEM)

% %% Show matricies
% stiffness_freeDofs = full(FEM.K_G(FEM.nf_g,FEM.nf_g))
% mass_freeDofs = full(FEM.M_G(FEM.nf_g,FEM.nf_g))
% 
% %% Solve externally
% [V,D] = eig(stiffness_freeDofs,mass_freeDofs);
% wHz = sqrt(diag(D))./(2*pi);