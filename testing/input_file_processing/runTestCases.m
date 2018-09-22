clear all; close all; clc
addpath(genpath(fullfile(pwd,'..','..','cofe_toolbox')));

suite = matlab.unittest.TestSuite.fromFolder(pwd);
% {suite.Name}'
result = suite.run
rt = table(result)


% suite = [...
%     matlab.unittest.TestSuite.fromFile('testBdfLines.m'),...
%     matlab.unittest.TestSuite.fromFile('testBdfFields.m'),...
%     matlab.unittest.TestSuite.fromFile('CastInputFieldTest.m'),...
% ];
