% Verification tests
% Anthony Ricciardi
%
classdef TestTenBar < matlab.unittest.TestCase
    methods (Test)
        function runStatic(testCase)
            staticSolution = Cofe(fullfile('nastran_runs','static.dat'));
        end
        function compareStatic(testCase)
            cofeStatic = Hdf5('static.h5');
            nastranStatic = Hdf5(fullfile('nastran_runs','static.h5'));
            compare = @() cofeStatic.compare(nastranStatic);
            testCase.verifyWarningFree(compare);
        end
        function runModes(testCase)
            modesSolution = Cofe(fullfile('nastran_runs','modes.dat'));
        end
        function compareModes(testCase)
            cofeModes = Hdf5('modes.h5');
            nastranModes = Hdf5(fullfile('nastran_runs','modes.h5'));
            compare = @() cofeModes.compare(nastranModes);
            testCase.verifyWarningFree(compare);
        end
        function runBuck(testCase)
            buckSolution = Cofe(fullfile('nastran_runs','buckling.dat'));
        end
        function compareBuck(testCase)
            cofeBuck = Hdf5('buckling.h5');
            nastranBuck = Hdf5(fullfile('nastran_runs','buckling.h5'));
            
            % check eigenvalues
            maxEigenvalueSquareDiff = max( (cofeBuck.summary.EIGEN - nastranBuck.summary.EIGEN).^2);
            testCase.verifyTrue (maxEigenvalueSquareDiff < 1e-8)
        end
    end
    
end