clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

%% Run cases
full = Cofe(fullfile('gitControlTestDir','cantilever_bar','no_super','noReduction.dat'),'writeOutput2Disk',false);
guyanNoSuper   = Cofe(fullfile('gitControlTestDir','cantilever_bar','no_super','guyanReduction.dat'),'writeOutput2Disk',false);
dynamicNoSuper = Cofe(fullfile('gitControlTestDir','cantilever_bar','no_super','dynamicReduction.dat'),'writeOutput2Disk',false);
guyan = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_guyan','guyanSuper.dat'),'writeOutput2Disk',false);
cb1 = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper1Mode.dat'),'writeOutput2Disk',false);
cb2 = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper2Modes.dat'),'writeOutput2Disk',false);
cb3 = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper3Modes.dat'),'writeOutput2Disk',false);

%% Print tables
full.solution(1).eigenvalueTable.printTextOutput(1)
guyanNoSuper.solution(1).eigenvalueTable.printTextOutput(1)
dynamicNoSuper.solution(1).eigenvalueTable.printTextOutput(1)
guyan.solution(1).eigenvalueTable.printTextOutput(1)
cb1.solution(1).eigenvalueTable.printTextOutput(1)
cb2.solution(1).eigenvalueTable.printTextOutput(1)
cb3.solution(1).eigenvalueTable.printTextOutput(1)

%%
% fullHdf5 = full.solution.solution2Hdf5(full.model);
% nastranFullHdf5 = Hdf5(fullfile('gitControlTestDir','cantilever_bar','no_super','noReduction.h5'));
% 
% delete('nastranFullHdf5Roundtrip.h5')
% nastranFullHdf5.export('nastranFullHdf5Roundtrip.h5')
% 
% delete('full.h5')
% fullHdf5.export('full.h5')
% getTable(fullHdf5.domains)


% 
% cb3Hdf5 = cb3.solution.solution2Hdf5(cb3.model);
% delete('cb3.h5')
% cb3Hdf5.export('cb3.h5')
