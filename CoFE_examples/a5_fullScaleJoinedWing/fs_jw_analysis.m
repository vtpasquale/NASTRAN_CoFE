
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
CASE.inputFile = 'fs_jw.bdf';
CASE.SOL = 103; % SOL = 101, SOL = 103, and SOL = 105 are options
CASE.SPC = 1;
CASE.LOAD = 88;
CASE.METHOD = 1;
CASE.RECOVER = 0;
CASE.WRITE_c06 = 1;

%% Run CoFE
FEM = CoFE_analysis(CASE);

% %% Read MSC Nastran Results for Comparison
% switch CASE.SOL
%     case 101
%         nas_response = nastran.punchRead('l_static');
%         nas_comment{1} = 'Linear Static';
%         nas_scaleOption = 2;
%     case 103
%         [nas_response,freq] = nastran.punchRead('modes');
%         for i = 1:size(freq,2)
%             nas_comment{i} = sprintf('Vibration Mode %d: %.4f Hz',i,freq(i));
%         end
%         nas_scaleOption = ones(size(freq,2));
% end
% 
% %% Plot results
% post_gui(FEM,nas_response,nas_comment,nas_scaleOption);
post_gui(FEM)