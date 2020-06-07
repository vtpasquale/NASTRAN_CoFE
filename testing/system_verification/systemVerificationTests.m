clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

f = runtests(pwd,'IncludeSubfolders',true)
table(f)