% Parametric tests for castInputField() function.
% Anthony Ricciardi
%
classdef TestRbe2Colinear < matlab.unittest.TestCase
    properties (TestParameter)
        k1 = {'','1'};
        k2 = {'','2'};
        k3 = {'','3'};
        k4 = {'','4'};
        k5 = {'','5'};
        k6 = {'','6'};
    end
    methods (TestMethodSetup)
        function warningOff(testCase)
            warning('off','compareWarn:hdf5_sorting')
        end
    end
    methods(TestMethodTeardown)
        function warningOn(testCase)
            warning('on','compareWarn:hdf5_sorting')
        end
    end
    methods (Test)
        function nastranCompare(testCase,k1,k2,k3,k4,k5,k6)
            str = [k1,k2,k3,k4,k5,k6];
            if ~isempty(str)
                [out,cofe] = ...
                    Cofe(fullfile('test_cases',['colinear-',str,'.dat']),...
                    'writeOutput2Disk',false,...
                    'getHdf5Object',true);
                
                nastranHdf5 = Hdf5(fullfile('test_cases','nastranSolution',['colinear-',str,'.h5']));
                % add model domain for consistency
                modelDomain = Hdf5Domains( model2Hdf5Domains(out.model) );
                modelDomain.ID = uint32(7);
                nastranHdf5.domains = nastranHdf5.domains.appendObj(modelDomain);
                
                compare = @() cofe.hdf5.compare(nastranHdf5);
                testCase.verifyWarningFree(compare);
            else
                %skip case with no contraints
            end
        end
    end
end