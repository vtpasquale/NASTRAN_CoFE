% Parametric tests for castInputField() function.
% Anthony Ricciardi
%
classdef TestCastInputField < matlab.unittest.TestCase
    properties (TestParameter)
        % sequential
        dataType = {'char','uint8','uint32','double'};
        dataDefault = {'DefaultCharInput',uint8(8),uint32(32),2.2};
        charFieldData = {'CharInput','80','320','22.2'};
        typedFieldData = {'CharInput',uint8(80),uint32(320),22.2};
        
        % other
        integerDataType = {'uint8','uint32'};
        numericDataType = {'uint8','uint32','double'};
    end
    properties
        entryName = 'ENTRY';
        fieldName = 'FIELD';
    end   
    methods (Test,ParameterCombination='sequential')
        function applyDefaultValue(testCase,dataType,dataDefault)
            % Defaut values are applied when fieldData is empty
            out = castInputField(testCase.entryName,testCase.fieldName,'',dataType,dataDefault);
            assert(all(out==dataDefault),'Default field value not applied.');
            assert(isa(out,dataType),'Default type assigned incorrectly.')
        end
        function castFieldValue(testCase,dataType,dataDefault,charFieldData,typedFieldData)
            % Cast field values are applied when fieldData is empty
            out = castInputField(testCase.entryName,testCase.fieldName,charFieldData,dataType,dataDefault);
            assert(all(out==typedFieldData),'Field value incorrect.');
            assert(isa(out,dataType),'Type assigned incorrectly.')
        end
    end
    methods (Test)
        function errorEmptyFieldWithNoDefault(testCase,dataType)
            % Error when a required field is empty
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,'',dataType,NaN);
            testCase.verifyError(testCall,'castInputField:emptyFieldWithNoDefault')
        end
        function errorBogusNumericInput(testCase,numericDataType)
            % Format error for bogus numeric inputs
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,'bogusInput',numericDataType,[]);
            testCase.verifyError(testCall,'castInputField:dataFormatIssue')
        end
        function errorNonintegerInputForInteger(testCase,integerDataType)
            % Error for noninteger field values input for integer types
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,'1.5',integerDataType,[]);
            testCase.verifyError(testCall,'castInputField:fieldShouldBeInteger');
        end
        function errorIntegerOutOfTypeStoreageRange(testCase,integerDataType)
            % Error for integer out of type storage range
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,num2str(double(intmax(integerDataType))+1),integerDataType,[]);
            testCase.verifyError(testCall,'castInputField:fieldValueOutsideIntegerRange')
            
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,num2str(double(intmin(integerDataType))-1),integerDataType,[]);
            testCase.verifyError(testCall,'castInputField:fieldValueOutsideIntegerRange')
        end
        function fieldDataLessThanDataMin(testCase,numericDataType)
            % Error when out < dataMin
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,'10',numericDataType,[],12);
            testCase.verifyError(testCall,'castInputField:fieldValueOutsideSpecifiedRange')
        end
        function fieldDataGreaterThanDataMax(testCase,numericDataType)
            % Error when out > datMax
            testCall = @()castInputField(testCase.entryName,testCase.fieldName,'10',numericDataType,[],5,8);
            testCase.verifyError(testCall,'castInputField:fieldValueOutsideSpecifiedRange')
        end
    end
end