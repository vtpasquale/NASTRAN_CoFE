clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

full = Hdf5(fullfile('gitControlTestDir','cantilever_bar','no_super','noReduction.h5'));
guyan = Hdf5(fullfile('gitControlTestDir','cantilever_bar','part_super_guyan','guyanSuper.h5'));
cb1 = Hdf5(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper1Mode.h5'));
cb2 = Hdf5(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper2Modes.h5'));
cb3 = Hdf5(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper3Modes.h5'));

baseline = full.summary.FREQ(1:4);
staticReduction = [guyan.summary.FREQ(1:2);NaN(2,1)];
oneModeSe = cb1.summary.FREQ(1:4);
twoModeSe = cb2.summary.FREQ(1:4);
threeModeSe =cb3.summary.FREQ(1:4);

fprintf(1,'%10.2f%10.2f%10.2f%10.2f%10.2f\n', [baseline,staticReduction,oneModeSe,twoModeSe,threeModeSe]' )



% baseline = sqrt(full.domains.TIME_FREQ_EIGR(2:5))./(2*pi);
% staticReduction = [sqrt(guyan.domains.TIME_FREQ_EIGR(4:5))./(2*pi);NaN(2,1)];
% oneModeSe = sqrt(cb1.domains.TIME_FREQ_EIGR(4:7))./(2*pi);
% twoModeSe = sqrt(cb2.domains.TIME_FREQ_EIGR(4:7))./(2*pi);
% threeModeSe = sqrt(cb3.domains.TIME_FREQ_EIGR(4:7))./(2*pi);


% delete('myTest.h5')
% 
% filename='myTest.h5';
% hdf5.export(filename)

% h5disp('myTest.h5','/NASTRAN/','min')
% h5disp('beams-rods.h5','/NASTRAN/RESULT/ELEMENTAL/ELEMENT_FORCE/')
% 
% h5disp('myTest.h5','/NASTRAN/RESULT/ELEMENTAL/ELEMENT_FORCE/')
% h5disp('beams-rods.h5','/NASTRAN/RESULT/ELEMENTAL/ELEMENT_FORCE/')
%
% h5disp('myTest.h5')
% h5disp('viewModed.h5')

% h5disp('tenbar-hdf5.h5')

