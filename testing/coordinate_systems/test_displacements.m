clearvars; close all; clc
addpath(genpath(fullfile('..','..','cofe_toolbox')));

%% Displacements in nodal displacement and basic reference frames vs nastran
% Read input
bdfLines  = BdfLines('truss_rand_coords.dat');
bdfFields = BdfFields(bdfLines);

% Process entries
caseEntry = CaseEntry.constructFromFields(bdfFields.caseControl);
bulkEntry = BulkEntry.constructFromFields(bdfFields.bulkData);

% Create case control and model
caseControl = caseEntry.entry2caseControl();
model = bulkEntry.entry2model();

% Assemble model
model = model.preprocess();
model = model.assemble();

% Solve
static = Static;
static = static.solve(caseControl,model);


% ENTRY = entry.import_entries('truss_rand_coords.dat');
% MODEL = ENTRY.entry2model_all();
% MODEL = MODEL.preprocess();
% MODEL = MODEL.assemble();




% STATIC=static();
% STATIC.CASE_CONTROL.LOAD = 1;
% % STATIC.CASE_CONTROL.DISPLACEMENT.n = 23;
% STATIC.CASE_CONTROL.DISPLACEMENT.all = true;
% % STATIC.CASE_CONTROL.OUTPUT_SETS(1).ID=23;
% % STATIC.CASE_CONTROL.OUTPUT_SETS(1).i1=1;
% % STATIC.CASE_CONTROL.OUTPUT_SETS(1).iN=10;
% % STATIC.CASE_CONTROL.OUTPUT_SETS(1).thru=1;
% 
% STATIC.CASE_CONTROL.FORCE.all = true;
% STATIC.CASE_CONTROL.STRESS.all = true;
% STATIC.CASE_CONTROL.STRAIN.all = true;
% STATIC.CASE_CONTROL.ESE.all = true;
% 
% STATIC=STATIC.solve(MODEL);
% 
% % read nastran results
% nastran_u_g = csvread('truss_rand_coords_u_g.csv',1,2);
% nastran_u_0 = csvread('truss_rand_coords_u_0.csv',1,2);
% 
% %fprintf(1,'%d\t%E\t%E\t%E\n',[double([MODEL.NODE.ID]'),STATIC.u_g(1:6:end),STATIC.u_g(2:6:end),STATIC.u_g(3:6:end)]')
% assert(max(max(abs(nastran_u_g-[STATIC.u_g(1:6:end),STATIC.u_g(2:6:end),STATIC.u_g(3:6:end)])))<1e-6)
% assert(max(max(abs(nastran_u_0-[STATIC.u_0(1:6:end),STATIC.u_0(2:6:end),STATIC.u_0(3:6:end)])))<1e-6)

%%
% STATIC.displacement
% STATIC.displacement_g.echo(1)
% STATIC.DB.writeNeu_all(1)