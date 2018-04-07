clear all; close all; clc
addpath(genpath(fullfile('..','..','cofe_toolbox')));

%% test case 1
ENTRY = entry.import_entries('testcase1.dat');
MODEL = ENTRY.entry2model_all();
MODEL = MODEL.preprocess();
MODEL = MODEL.assemble();


%% Nodes converted to basic coordinate system using Femap
refENTRY = entry.import_entries('testcase1_basic.dat');
refMODEL = refENTRY.entry2model_all();
refMODEL = refMODEL.preprocess();
refMODEL = refMODEL.assemble();

%% Compare
% bar(sqrt(sum(([[MODEL.NODE.X_0]-[refMODEL.NODE.X_0]]./[refMODEL.NODE.X_0]).^2)))
[[MODEL.NODE.X_0];[refMODEL.NODE.X_0]]