% Verification tests
% Anthony Ricciardi
%
classdef Test72Bar < matlab.unittest.TestCase
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
            
            % Repeat eigenvalues complicates eigenvector comparison
            % compare = @() cofeModes.compare(nastranModes);
            % testCase.verifyWarningFree(compare);
            
            % Compare eigenvalues only
            normalizedDifference = calculateNormalizedDifference(...
                cofeModes.summary.EIGEN,nastranModes.summary.EIGEN);
            assert(all( normalizedDifference<1e-10),'Eigenvalue comparison failed')
        end
    end
    
end