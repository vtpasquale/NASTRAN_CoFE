% Anthony Ricciardi
% Call NASTRAN to excecure file in this directory
clear; close all; clc

addpath('Z:\NASTRAN\AR_NASTRAN_Toolbox')

%% User Inputs

extension = '.dat';
% 
% filename = 'L_static';
% callNASTRAN_4_host(filename,extension)

% filename = 'Modes';
% callNASTRAN_4_host(filename,extension)
% 
filename = 'L_Buck';
callNASTRAN_4_host(filename,extension)
