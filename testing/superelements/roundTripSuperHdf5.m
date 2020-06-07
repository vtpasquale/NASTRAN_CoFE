clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

delete('cb3roundtrip.hdf5');
cb3 = Hdf5(fullfile('gitControlTestDir','cantilever_bar','part_super_cb','cbSuper3Modes.h5'));

cb3.export('cb3roundtrip.hdf5')