clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));

% add stress and strain from cofe process.

%% CoFE Solution
staticSolution = Cofe(fullfile('nastran_runs','static.dat'));
modesSolution = Cofe(fullfile('nastran_runs','modes.dat'));
cofeStatic =  Hdf5('static.h5');
cofeModes = Hdf5('modes.h5');

%% Read Nastran output
nastranStatic = Hdf5(fullfile('nastran_runs','static.h5'));
nastranModes = Hdf5(fullfile('nastran_runs','modes.h5'));

%% Compare Hdf5 results
cofeStatic.compare(nastranStatic)
cofeModes.compare(nastranModes)

