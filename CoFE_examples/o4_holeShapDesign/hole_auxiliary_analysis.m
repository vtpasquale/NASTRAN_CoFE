
%% Clear memory and set path
clearvars; close all; clc
home = pwd; cd ..; cd ..; base = pwd; cd(home);
addpath(fullfile(base,'CoFE_toolbox'))

%% CASE data
inputFile = 'd200cs_aux.bdf';
CASE = case_obj;
CASE.SOL = 101;
CASE.SPC = 25;
CASE.LOAD = 100;
CASE.STRESS = 1;
CASE.STRAIN = 1;
CASE.ESE = 1;
CASE.PRINT = 0;

CASE(2) = CASE(1); CASE(2).LOAD = 101;
CASE(3) = CASE(1); CASE(3).LOAD = 102;
CASE(4) = CASE(1); CASE(4).LOAD = 103;
CASE(5) = CASE(1); CASE(5).LOAD = 104;
CASE(6) = CASE(1); CASE(6).LOAD = 105;
CASE(7) = CASE(1); CASE(7).LOAD = 106;

%% Run CoFE
FEM = CoFE_analysis(inputFile,CASE);

%% Post process
CoFE_view(FEM);
axis equal

%% Scale Basis Vectors to Unit Maximum Displacement
ind = [];
for n = 1:40;
    ind = [ind,(1:3)+(n-1)*6];
end
unscaledBV = [FEM.u];
unscaledBV = unscaledBV(ind,:);
BV = unscaledBV .* repmat(1./max(abs(unscaledBV)),[size(unscaledBV,1),1]);
