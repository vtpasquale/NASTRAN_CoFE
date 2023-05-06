clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

%% Run analyses
cofe = Cofe('seventyTwoBarTruss.bdf');
disp(cofe)