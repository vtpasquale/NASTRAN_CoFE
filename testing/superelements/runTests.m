clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));

suite = matlab.unittest.TestSuite.fromClass(?TestModelSets);
testResult = suite.run;

table(testResult)