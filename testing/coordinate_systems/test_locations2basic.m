% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','cofe_toolbox')));

%% Trasform locations to basic reference frame - simple case

% model with nodes specified in local coordinate systems
ENTRY = entry.import_entries('simple_case.dat');
MODEL = ENTRY.entry2model_all();
MODEL = MODEL.preprocess();

% model with nodes converted to basic coordinate system using Femap
refENTRY = entry.import_entries('simple_case_basic.dat');
refMODEL = refENTRY.entry2model_all();
refMODEL = refMODEL.preprocess();

% compare values in basic coordinate system
assert(max(max(abs([[MODEL.NODE.X_0]-[refMODEL.NODE.X_0]])))<1e-5) % [[MODEL.NODE.X_0];[refMODEL.NODE.X_0]]

%% Transform locations to basic reference frame - complex case

% model with nodes specified in local coordinate systems
ENTRY = entry.import_entries('complex_case.dat');
MODEL = ENTRY.entry2model_all();
MODEL = MODEL.preprocess();

% model with nodes converted to basic coordinate system using Femap
refENTRY = entry.import_entries('complex_case_basic.dat');
refMODEL = refENTRY.entry2model_all();
refMODEL = refMODEL.preprocess();

% compare values in basic coordinate system
assert(max(max(abs([[MODEL.NODE.X_0]-[refMODEL.NODE.X_0]])))<5e-4) % [[MODEL.NODE.X_0];[refMODEL.NODE.X_0]]
% large field formatting would have allowed for tighter tolerances