% Parametric tests for model sets
% Anthony Ricciardi
%
classdef TestModelSets < matlab.unittest.TestCase
    
    properties (ClassSetupParameter)
        file = {fullfile('gitControlTestDir','cantilever_bar'         ,'no_super'        ,'noReduction'),...
                fullfile('gitControlTestDir','cantilever_bar'         ,'no_super'        ,'guyanReduction'),...
                fullfile('gitControlTestDir','cantilever_bar'         ,'no_super'        ,'dynamicReduction'),...
                fullfile('gitControlTestDir','cantilever_bar'         ,'part_super_guyan','guyanSuper'),...
                fullfile('gitControlTestDir','cantilever_bar'         ,'part_super_cb'   ,'cbSuper1Mode'),...
                fullfile('gitControlTestDir','cantilever_bar'         ,'part_super_cb'   ,'cbSuper2Modes'),...
                fullfile('gitControlTestDir','cantilever_bar'         ,'part_super_cb'   ,'cbSuper3Modes'),...
                fullfile('gitControlTestDir','cantilever_bar_scramble','part_super_cb'   ,'cbSuper3Modes')}
    end
    
    properties (TestParameter)
        % compareSet = {'s','o','q','r','a','b','c','t','f'};
          compareSet = {'s','o','q','r','a','c','t','f'}; % ignoring b set
        % superelement = {1,2,3};
    end
    
    properties
        modelCoFE
        modelNas
    end
    
    methods (TestClassSetup)
        function ClassSetup(testCase, file)
            
            % Read dofSets from F06
            dofSets = getSetsFromF06(lower([file,'.f06']));
            
            % Read in model from input file, creat duplicate, then overwrite DofSet - then preprocess and compare both model objects
            cofe = Cofe([file,'.dat'],'assemble',false);
            testCase.modelCoFE = cofe.model;
            testCase.modelNas = testCase.modelCoFE;
            
            for s = 1:size(testCase.modelNas,1)
                testCase.modelNas(s).dofSet = dofSets{s};
                testCase.modelNas(s) = testCase.modelNas(s).dofSet.fromNastranSets(testCase.modelNas(s));
            end
        end
    end
    
    methods (Test)
        function testClass(testCase,compareSet)
            for superelement = 1:size(testCase.modelNas,1)
                testCase.verifyEqual(...
                    testCase.modelCoFE(superelement).(compareSet),...
                    testCase.modelNas(superelement).(compareSet))
            end
        end
    end
    
end

