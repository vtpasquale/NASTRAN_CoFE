clearvars; close all; clc
addpath(genpath(fullfile('..','..','cofe_toolbox')));

f = runtests(pwd,'IncludeSubfolders',true)
table(f)