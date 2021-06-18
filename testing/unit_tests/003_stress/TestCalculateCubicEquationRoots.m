% Class to unit test calculateCubicEquationRoots() function.

% Anthony Ricciardi
% June 2021
classdef TestCalculateCubicEquationRoots < matlab.unittest.TestCase
    properties (TestParameter)
        % sequential
        inputDimensions = {1,2,3,5};
        coefficientPermutation = {'a','b','c','d'};
        coefficentType = {'real','complex'};
        
        aValues = {-10*rand(1) 10*rand(1)};
        bValues = {-10*rand(1) 0 rand(1)};
        cValues = {-10*rand(1) 0 rand(1)};
        dValues = {-10*rand(1) 0 rand(1)};
    end
    methods (Test)
        function inputSignsAndZerosCheck(testCase,aValues,bValues,cValues,dValues)
            [x1,x2,x3] = calculateCubicEquationRoots(aValues,bValues,cValues,dValues);
            residual = testCase.calculateResidual(aValues,bValues,cValues,dValues,x1,x2,x3);
            if residual > 1e-12
                error('Root calculation accuracy fail.')
            end
        end
        function arrayInputSignsAndZerosCheck(testCase)
            aValues = [-10*rand(1)   10*rand(1)];
            bValues = [-10*rand(1) 0 10*rand(1)];
            cValues = [-10*rand(1) 0 10*rand(1)];
            dValues = [-10*rand(1) 0 10*rand(1)];
            a=zeros(2,3,3,3);
            b=a;
            c=a;
            d=a;
            % use an ugly for loop to make this simple. 
            for ia = 1:2
                for ib = 1:3
                    for ic = 1:3
                        for id = 1:3
                            a(ia,ib,ic,id) = aValues(ia);
                            b(ia,ib,ic,id) = bValues(ib);
                            c(ia,ib,ic,id) = cValues(ic);
                            d(ia,ib,ic,id) = dValues(id);
                        end
                    end
                end
            end
            [x1,x2,x3] = calculateCubicEquationRoots(a,b,c,d);
            residual = testCase.calculateResidual(a,b,c,d,x1,x2,x3);
            if residual > 1e-12
                error('Root calculation accuracy fail.')
            end
            testCase.sortCheck(x1,x2,x3)
        end
        function worksForDifferentArrayDimensions(testCase,inputDimensions,coefficentType)
            % Error when a required field is empty
            
            a = testCase.makeRandomSizeInputMatrix(inputDimensions,coefficentType);
            sizeA = size(a);
            b = myRandom(sizeA,coefficentType);
            c = myRandom(sizeA,coefficentType);
            d = myRandom(sizeA,coefficentType);
            [x1,x2,x3] = calculateCubicEquationRoots(a,b,c,d);
            residual = testCase.calculateResidual(a,b,c,d,x1,x2,x3);
            if residual > 1e-8
                error('Root calculation accuracy fail.')
            end
            testCase.sortCheck(x1,x2,x3)
        end
        function worksWhenD0EqualsZero(testCase,coefficentType)
            a = testCase.makeRandomSizeInputMatrix(3,coefficentType);
            sizeA = size(a);
            c = myRandom(sizeA,coefficentType);
            d = myRandom(sizeA,coefficentType);
            b = sqrt(3.*a.*c);
            [x1,x2,x3] = calculateCubicEquationRoots(a,b,c,d);
            residual = testCase.calculateResidual(a,b,c,d,x1,x2,x3);
            if residual > 1e-8
                error('Root calculation accuracy fail.')
            end
            testCase.sortCheck(x1,x2,x3)
        end
        function worksWhenD0AndD1NearOrEqualZero(testCase,coefficentType)
            a = testCase.makeRandomSizeInputMatrix(3,coefficentType);
            sizeA = size(a);
            c = myRandom(sizeA,coefficentType);
            b = sqrt(3.*a.*c);
            d = ( 2*b.^3 - 9*a.*b.*c)./(-27*a.^2) ;
            [x1,x2,x3] = calculateCubicEquationRoots(a,b,c,d);
            residual = testCase.calculateResidual(a,b,c,d,x1,x2,x3);
            if residual > 1e-8
                error('Root calculation accuracy fail.')
            end
            testCase.sortCheck(x1,x2,x3)
        end
        function errorWhenQuadratic(testCase,inputDimensions)
            % Error when one input matrix is a different size than others
            a = testCase.makeRandomSizeInputMatrix(inputDimensions,'real');
            sizeA = size(a);
            b = rand(sizeA);
            c = rand(sizeA);
            d = rand(sizeA);
            
            % change one a term to zero
            a(1)=0;
                    
            testCall = @()calculateCubicEquationRoots(a,b,c,d);
            testCase.verifyError(testCall,'cubicRoots:InputQuadratic')
        end
        function errorDifferentInputArraySizes(testCase,inputDimensions,coefficientPermutation)
            % Error one input matrix is a different size than others
            a = testCase.makeRandomSizeInputMatrix(inputDimensions,'real');
            sizeA = size(a);
            b = rand(sizeA);
            c = rand(sizeA);
            d = rand(sizeA);
            
            % change one matrix
            differentSize = sizeA;
            differentSize(end) = differentSize(end)+1;
            eval(sprintf('%s=rand(differentSize);',coefficientPermutation) );
                    
            testCall = @()calculateCubicEquationRoots(a,b,c,d);
            testCase.verifyError(testCall,'cubicRoots:InputSize')
        end
    end
    methods (Static=true)
        function matrix = makeRandomSizeInputMatrix(inputDimensions,type)
            dimensions = randi(4,1,inputDimensions);
            matrix = myRandom(dimensions,type);
        end
        function residual = calculateResidual(a,b,c,d,x1,x2,x3)
            zero1 = a.*x1.^3 + b.*x1.^2 + c.*x1 + d;
            zero2 = a.*x2.^3 + b.*x2.^2 + c.*x2 + d;
            zero3 = a.*x3.^3 + b.*x3.^2 + c.*x3 + d;
            residual = max(abs([zero1(:);zero2(:);zero3(:)]));
        end
        function sortCheck(x1,x2,x3)
            check1 = abs(x1)<abs(x2);
            check2 = abs(x1)<abs(x3);
            check3 = abs(x2)<abs(x3);
            if any([check1(:);check2(:);check3(:)])
                error('Root sorting failure')
            end
        end
    end
end

function matrix = myRandom(dimensions,type)
% Makes uniform distribution random matrix on the interval(-10,10). Can be
% real or complex
switch type
    case 'real'
        matrix =10*(2*rand(dimensions)-1);
    case 'complex'
        matrix =10*(2*rand(dimensions)-1) + 1i*10*(2*rand(dimensions)-1);
    otherwise
        error('Type not supported.')
end
end