clearvars; close all; clc
addpath(genpath(fullfile('..','..','cofe_toolbox')));

%%
ENTRY = entry.import_entries('rt.bdf');

%% 
ENTRY.echo_all(1)

%%
MODEL = ENTRY.entry2model_all();

%%
MODEL = MODEL.preprocess();

%%
STATIC=static();
STATIC=STATIC.solve(MODEL);