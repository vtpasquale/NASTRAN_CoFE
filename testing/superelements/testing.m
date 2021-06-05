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
cb3scram = Cofe(fullfile('gitControlTestDir','cantilever_bar_scramble','part_super_cb','cbSuper3Modes.dat'),'writeOutput2Disk',false);

%% Print tables
full.solution(1).eigenvalueTable.printTextOutput(1)
guyanNoSuper.solution(1).eigenvalueTable.printTextOutput(1)
dynamicNoSuper.solution(1).eigenvalueTable.printTextOutput(1)
guyan.solution(1).eigenvalueTable.printTextOutput(1)
cb1.solution(1).eigenvalueTable.printTextOutput(1)
cb2.solution(1).eigenvalueTable.printTextOutput(1)
cb3.solution(1).eigenvalueTable.printTextOutput(1)
cb3scram.solution(1).eigenvalueTable.printTextOutput(1)

%%
% Read dofSets from F06
dofSets = getSetsFromF06(fullfile('gitControlTestDir','cantilever_bar_scramble','part_super_cb','cbSuper3Modes.f06'));

% Read in model from input file, creat duplicate, then overwrite DofSet - then preprocess and compare both model objects
testCase.modelCoFE = cb3scram.model;
testCase.modelNas = testCase.modelCoFE;
for s = 1:size(testCase.modelNas,1)
    testCase.modelNas(s).dofSet = dofSets{s};
    testCase.modelNas(s) = testCase.modelNas(s).dofSet.fromNastranSets(testCase.modelNas(s));
end


compareSets = {'s','o','q','r','a','c','t','f'};
for superelement = 1:size(testCase.modelNas,1)
    for cs = 1:size(compareSets,2)
        compareSet = compareSets{cs};
        if any(testCase.modelCoFE(superelement).(compareSet)~= testCase.modelNas(superelement).(compareSet) )
            error('Set difference')
        end
    end
end
