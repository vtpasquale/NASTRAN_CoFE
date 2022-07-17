% Verification tests
% Anthony Ricciardi
%
classdef TestSvanbergBar < matlab.unittest.TestCase
    methods (Test)
        function compareMassAndStiffness(testCase)
            matSolution = Cofe(fullfile('nastran_runs','barmat.dat'),'stopBefore','solve');
            ck = matSolution.model.element(1).k_e;
            cm = matSolution.model.element(1).m_e;
            
            nas = load(fullfile('nastran_runs','barMatrices.mat'),'k','m');
            kDelta = calculateNormalizedDifference(nas.k,ck);
            mDelta = calculateNormalizedDifference(nas.m,cm);
            assert(max(max(abs(kDelta)))<1e-8,'Stiffness matrix difference exceeds tolerance.')
            assert(max(max(abs(mDelta)))<1e-8,'Mass matrix difference exceeds tolerance.')
        end
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
            
            % compare finds some irrelevant differences
            warning('off','compareFail:hdf5_NASTRAN_RESULT_NODAL_SPC_FORCE')
            warning('off','compareFail:hdf5_NASTRAN_RESULT_ELEMENTAL_ELEMENT_FORCE_BAR')
            
            testCase.verifyWarningFree(compare);
            
            warning('on','compareFail:hdf5_NASTRAN_RESULT_NODAL_SPC_FORCE')
            warning('on','compareFail:hdf5_NASTRAN_RESULT_ELEMENTAL_ELEMENT_FORCE_BAR')
        end
    end
    
end