
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'gt13ex2.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 100;
CASE.LOAD = 5;
CASE.METHOD = 30;
CASE.STRESS = 1;
CASE.STRAIN = 1;
CASE.ESE = 1;
CASE.EKE = 1;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post process
CoFE_view(FEM);
view(-45,30)
axis equal

% % %% MSC Nastran comparison
% % nas_response = nastran.punchRead('gt13ex2');
% % nas_comment{1} = 'Linear Static';
% % nas_scaleOption = 2;
% % 
% % %% Plot results
% % post_gui(FEM,nas_response,nas_comment,nas_scaleOption);
% % axis equal
% % view(-50,20)

% %%
% 100*(min(FEM.x)-min(nas_response(:,4)))./min(nas_response(:,4))