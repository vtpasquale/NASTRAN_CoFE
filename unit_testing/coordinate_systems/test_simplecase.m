clear all; close all; clc
addpath(genpath(fullfile('..','..','cofe_toolbox')));

%% test case 1
ENTRY = entry.import_entries('simple_case.dat');
MODEL = ENTRY.entry2model_all();
MODEL = MODEL.preprocess();

%% Nodes converted to basic coordinate system using Femap
refENTRY = entry.import_entries('simple_case_basic.dat');
refMODEL = refENTRY.entry2model_all();
refMODEL = refMODEL.preprocess();

%% Compare
[[MODEL.NODE.X_0];[refMODEL.NODE.X_0]]