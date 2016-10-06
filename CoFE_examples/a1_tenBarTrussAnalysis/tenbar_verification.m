
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'tenBar_analysis.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 1;
CASE.LOAD = 88;
CASE.METHOD = 30;
CASE.STRESS=1;
CASE.STRAIN=1;
CASE.ESE=1;
CASE.EKE=1;

% SUBCASE 2
CASE(2) = CASE(1);
CASE(2).SOL = 103;

% SUBCASE 3
CASE(3) = CASE(1);
CASE(3).SOL = 105;
CASE(3).REF_LC = 1;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Read MSC Nastran Results for Comparison
% SOL 101
nas_response1 = nastran.punchRead(fullfile('NASTRAN_Comparisons','l_static'));
k = 1;
nas_comment{k} = 'Linear Static 1';  k = k + 1;
nas_scaleOption = 2;

% SOL 103
[nas_response2,freq] = nastran.punchRead(fullfile('NASTRAN_Comparisons','modes'));
for i = 1:size(freq,2)
    nas_comment{k} = sprintf('Vibration Mode %d: %.4f Hz',i,freq(i)); k = k + 1;
end
nas_scaleOption = [nas_scaleOption, ones(1,size(freq,2))];

% SOL 105
[nas_response3,~,ev] = nastran.punchRead(fullfile('NASTRAN_Comparisons','l_buck'));
nas_response3=nas_response3(:,:,2:end);
for i = 2:size(ev,2)
    nas_comment{k} = sprintf('Buckling Mode %d: ev = %.4f',i,ev(i)); k = k + 1;
end
nas_scaleOption = [nas_scaleOption, ones(1,size(ev,2))];

% all 
nas_response(:,:,1:size(nas_response1,3)) = nas_response1;
nas_response(:,:,size(nas_response,3)+(1:size(nas_response2,3))) = nas_response2;
nas_response(:,:,size(nas_response,3)+(1:size(nas_response3,3))) = nas_response3;

%% Plot results
verification_gui(FEM,nas_response,nas_comment,nas_scaleOption);
view(0,0)