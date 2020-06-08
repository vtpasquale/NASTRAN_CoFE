clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));


%% Read Nastran output
nastranStatic = Hdf5(fullfile('nastran_runs','static.h5'));
nastranModes = Hdf5(fullfile('nastran_runs','modes.h5'));

cofeStatic = Cofe(fullfile('nastran_runs','static.dat')); 
cofeModes = Cofe(fullfile('nastran_runs','modes.dat')); 

modesHdf5 = cofeModes.solution.solution2Hdf5(cofeModes.model);
staticHdf5 = cofeStatic.solution.solution2Hdf5(cofeStatic.model);

% getTable(modesHdf5.domains)
% getTable(nastranModes.domains)
% getTable(staticHdf5.domains)
% getTable(nastranStatic.domains)

% cofeModes.solution(1).baseHdf5DomainID
% cofeModes.solution(1).vectorHdf5DomainID

%% Run cases
% full = Cofe(fullfile('gitControlTestDir','cantilever_bar','no_super','noReduction.dat'),'output',false);
% guyanNoSuper   = Cofe(fullfile('gitControlTestDir','cantilever_bar','no_super','guyanReduction.dat'),'output',false);
% dynamicNoSuper = Cofe(fullfile('gitControlTestDir','cantilever_bar','no_super','dynamicReduction.dat'),'output',false);
% guyan = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_guyan','guyanSuper.dat'),'output',false);
% cb1 = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper1Mode.dat'),'output',false);
% cb2 = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper2Modes.dat'),'output',false);
% cb3 = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper3Modes.dat'),'output',false);

% %% Print tables
% full.solution(1).eigenvalueTable.printTextOutput(1)
% guyanNoSuper.solution(1).eigenvalueTable.printTextOutput(1)
% dynamicNoSuper.solution(1).eigenvalueTable.printTextOutput(1)
% guyan.solution(1).eigenvalueTable.printTextOutput(1)
% cb1.solution(1).eigenvalueTable.printTextOutput(1)
% cb2.solution(1).eigenvalueTable.printTextOutput(1)
% cb3.solution(1).eigenvalueTable.printTextOutput(1)
