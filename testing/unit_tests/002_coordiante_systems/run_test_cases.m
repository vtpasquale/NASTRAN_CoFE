clear all; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

results = runtests;
table(results)