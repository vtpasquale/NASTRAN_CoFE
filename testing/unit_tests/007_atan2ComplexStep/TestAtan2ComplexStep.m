% Tests for atan2ComplexStep() function.
%
% % TYPE
% >> TestAtan2ComplexStep.runTestCases()

% Anthony Ricciardi
% October 2021
classdef TestAtan2ComplexStep < matlab.unittest.TestCase
    methods (Test)
        function scalars(testCase)
            Y = 2*rand(1)-1;
            X = 2*rand(1)-1;
            testCase.compare(Y,X);
        end
        function arraysDim1(testCase)
            Y = 2*rand(10,1)-1;
            X = 2*rand(10,1)-1;
            testCase.compare(Y,X);
        end
        function arraysDim2(testCase)
            Y = 2*rand(1,10)-1;
            X = 2*rand(1,10)-1;
            testCase.compare(Y,X);
        end
        function arrays2D(testCase)
            Y = 2*rand(10,10)-1;
            X = 2*rand(10,10)-1;
            testCase.compare(Y,X);
        end
        function arraysND(testCase)
            Y = 2*rand(3,4,2)-1;
            X = 2*rand(3,4,2)-1;
            testCase.compare(Y,X);
        end
        function edgeCases(testCase)
            X = [1 -1 0 1 -1  0  1 -1];
            Y = [0  0 1 1  1 -1 -1 -1];
            testCase.compare(Y,X);
        end
        function arraysNDWithEdgeCases(testCase)
            Y = 2*rand(10,4,3)-1;
            X = 2*rand(10,4,3)-1;
            X(1:8)=[1 -1 0 1 -1  0  1 -1];
            Y(1:8)=[0  0 1 1  1 -1 -1 -1];
            testCase.compare(Y,X);
        end
        function arraysNDWithEdgeCases2(testCase)
            Y = 2*rand(10,4,3)-1;
            X = 2*rand(10,4,3)-1;
            X(1:8)=[1 -1 0 1 -1  0  1 -1];
            X(end-7:end)=[1 -1 0 1 -1  0  1 -1];
            X(end-7:end)=[0  0 1 1  1 -1 -1 -1];
            testCase.compare(Y,X);
        end
    end
    methods
        function compare(testCase,Y,X)
            maxDiff = testCase.compareFunction(Y,X);
            testCase.assertLessThan(maxDiff,1e-14);
            
            [maxAnalyticDiff,maxFdDiff] = testCase.compareGradient(Y,X);
            testCase.assertLessThan(maxAnalyticDiff,1e-14);
            testCase.assertLessThan(maxFdDiff,1e-5);
        end
    end
    methods (Static=true)
        function runTestCases()
            t = runtests;
            table(t)
        end
        function maxDiff = compareFunction(Y,X)
            T = atan2ComplexStep(Y,X);
            TMatlab = atan2(Y,X);
            diff = T-TMatlab;
            maxDiff=max(abs(diff(:)));
        end
        function [maxAnalyticDiff,maxFdDiff] = compareGradient(Y,X)
            
            % complex step
            dcs = 1e2*eps;
            csdy = atan2ComplexStep(Y+1i*dcs,X);
            csDtdy = imag(csdy)./dcs;
            csdx = atan2ComplexStep(Y,X+1i*dcs);
            csDtdx = imag(csdx)./dcs;
            
            % analytic            
            dtdx=-Y./(X.^2+Y.^2);
            dtdy= X./(X.^2+Y.^2);
            AnalyticDiff = [csDtdy-dtdy; csDtdx-dtdx];
            maxAnalyticDiff = max(abs(AnalyticDiff(:)));
            
            % finite difference 
            dfd = 1e8*eps;
            T = atan2(Y,X);
            fddy = atan2(Y+dfd,X);
            fdDtdy = (fddy-T)./dfd;
            fddx = atan2(Y,X+dfd);
            fdDtdx = (fddx-T)./dfd;
                        
            AnalyticDiff = [fdDtdy-csDtdy; fdDtdx-csDtdx];
            maxFdDiff = max(abs(AnalyticDiff(:)));
            
        end
    end
end