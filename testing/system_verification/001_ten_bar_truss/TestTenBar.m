% Verification tests
% Anthony Ricciardi
%
classdef TestTenBar < matlab.unittest.TestCase
    methods (Test)
        function runStatic(testCase)
            staticSolution = Cofe(fullfile('nastran_runs','static.dat'));
        end
        function compareStatic(testCase)
            compare = @() cofeStatic.compare(nastranStatic);
            testCase.verifyThat(compare, IssuesNoWarnings());
        end
        function runModes(testCase)
            staticSolution = Cofe(fullfile('nastran_runs','static.dat'));
        end
        function compareModes(testCase)
            compare = @() cofeStatic.compare(nastranStatic);
            testCase.verifyThat(compare, IssuesNoWarnings());
        end
    end
    
end