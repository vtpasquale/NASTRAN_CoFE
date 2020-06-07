clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

%% Run cases
cofe = Cofe(fullfile('gitControlTestDir','cantilever_bar','part_super_guyan','guyanSuperStatic.dat'),'output',false);