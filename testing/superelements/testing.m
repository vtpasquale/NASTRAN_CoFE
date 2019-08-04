clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

%% Displacements in nodal displacement and basic reference frames vs nastran
% Process input file(s)
% bdfLines  = BdfLines(fullfile('gitControlTestDir','cantileverBarFull.dat'));
% bdfLines  = BdfLines('sets.dat');
% bdfLines  = BdfLines(fullfile('gitControlTestDir','cantileverBarFixedBoundaryReductionPartSuper.dat'));
% bdfLines  = BdfLines(fullfile('gitControlTestDir','cantileverBarGuyanReduction.dat'));
bdfLines  = BdfLines(fullfile('gitControlTestDir','cantileverBarGuyanReductionPartSuper.dat'));
bdfFields = BdfFields(bdfLines);

% Create entry object arrays from fields
bdfEntries = BdfEntries(bdfFields);
model = bdfEntries.entries2model();

% Assemble model
model = model.preprocess();
model = model.assemble();

% Solve
solver = Solver.constructFromModel(model);
solver = solver.solve(model);

% solver.displacement_g.echo(1)
% solver.spcforces_g.echo(1)
solver(1).eigenvalueTable.echo(1)