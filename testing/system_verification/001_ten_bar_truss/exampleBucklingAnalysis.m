clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));

%% Run analyses
buckling = Cofe(fullfile('nastran_runs','buckling.dat'));