
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
CASE.inputFile = 'gt13ex2.bdf';
CASE.SOL = 101;
CASE.SPC = 100;
CASE.LOAD = 5;
CASE.METHOD = 10;
CASE.RECOVER = 0;
CASE.WRITE_c06 = 0;

%% Run CoFE
FEM = CoFE_analysis(CASE);

%% MSC Nastran comparison
nas_response = nastran.punchRead('gt13ex2');
nas_comment{1} = 'Linear Static';
nas_scaleOption = 2;

%% Plot results
post_gui(FEM,nas_response,nas_comment,nas_scaleOption);
axis equal
view(-50,20)

%%
100*(min(FEM.x)-min(nas_response(:,4)))./min(nas_response(:,4))