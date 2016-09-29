
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'fullJW.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 1025;
CASE.METHOD = 1;
CASE.STRESS = 0;
CASE.STRAIN = 0;
CASE.ESE = 0;
CASE.EKE = 0;

CASE(2) = CASE(1);
CASE(2).SOL = 103;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Read MSC Nastran Results for Comparison
% SOL 101
nas_response1 = nastran.punchRead('l_static');
k = 1;
nas_comment{k} = 'Linear Static 1';  k = k + 1;
nas_scaleOption = 2;

% SOL 103
[nas_response2,freq] = nastran.punchRead('modes');
for i = 1:size(freq,2)
    nas_comment{k} = sprintf('Vibration Mode %d: %.4f Hz',i,freq(i)); k = k + 1;
end
nas_scaleOption = [nas_scaleOption, ones(1,size(freq,2))];

% all 
nas_response(:,:,1:size(nas_response1,3)) = nas_response1;
nas_response(:,:,size(nas_response,3)+(1:size(nas_response2,3))) = nas_response2;

%% Plot results
verification_gui(FEM,nas_response,nas_comment,nas_scaleOption)
