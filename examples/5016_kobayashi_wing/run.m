clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

cofe = Cofe('kobayashi_wing.dat','writeOutput2Disk',false);