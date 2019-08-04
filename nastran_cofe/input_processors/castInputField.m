% Return checked input field data cast to requested type from field data input as [char]
% Anthony Ricciardi
%
% Inputs
% entryName [char] entry name, used for potential error messages
% fieldName [char] field name, used for potential error messages
% fieldData [char] raw field data from input file
% dataType  [char] data type.
%      Supported options: (type help class for more details)
%       char            -- Character
%       uint8           -- 8-bit unsigned integer
%       uint32          -- 32-bit unsigned integer
%       double          -- Double precision floating point number (this is the traditional MATLAB numeric type)
% dataDefault [type, [], NaN] default value.
%                        Set to NaN if explicit user input is required.
%                        Set to []  if user input is optional.
% dataMin:    [numeric] minimum value - optional - only used for numeric types
% dataMax:    [numeric] maximum value - optional - only used for numeric types
%
% Outputs
% out [dataType] checked input field data cast to specified dataType
%
function out = castInputField(entryName,fieldName,fieldData,dataType,dataDefault,dataMin,dataMax)

%% Check inputs
if nargin < 5; error('castInputField:missingInputs','At least 5 input arguments are requred for castInputField().'); end
if ~all([ischar(entryName),ischar(fieldName),ischar(fieldData),ischar(dataType)])
    error('castInputField:wrongInputDataType',...
          'Input arguments entryName, fieldName, fieldData, and dataType should be type [char].')
end

%% Empty field checks
if strcmp(fieldData,'');
    if isnan(dataDefault)
        error('castInputField:emptyFieldWithNoDefault',...
            'The %s field is required for %s entries.',fieldName,entryName)
    elseif isempty(dataDefault)
        out = dataDefault;
        return
    else
        out = dataDefault;
        if ~isa(out,dataType)
            error('castInputField:dataDefaultShouldMatchDataType',...
            'When a default field value is specified, class(default) should match the class specified by the "dataType" input.')
        end
        return
    end
end
    
%% Check and cast output
switch dataType
    case 'char'
        out = fieldData;
    case 'double' 
        % deal with scientific notation
        exponentSignLocation = strfind(fieldData(2:end),'-');
        if isempty(exponentSignLocation) 
            exponentSignLocation = strfind(fieldData(2:end),'+');
        end
        if ~isempty(exponentSignLocation)
            exponentLocation = strfind(upper(fieldData(2:end)),'E');
            if isempty(exponentLocation)
                fieldDataNew = [fieldData,' '];
                fieldDataNew(exponentSignLocation+2:end) = fieldData(exponentSignLocation+1:end);
                fieldDataNew(exponentSignLocation+1)='E';
                fieldData = fieldDataNew;
            elseif exponentSignLocation-exponentLocation ~= 1
                error('castInputField:dataFormatIssue',...
                      'There is a formating problem with the %s field on a(n) %s entry.',fieldName,entryName)
            end
        end
        out = sscanf(fieldData,'%f'); % out = str2double(data);
        if any([isnan(out),isempty(out)])
            error('castInputField:dataFormatIssue',...
                'There is a formating problem with the %s field on a(n) %s entry.',fieldName,entryName)
        end
    case {'uint8','uint32'}
        out = sscanf(fieldData,'%f'); % out = str2double(data);
        if any([isnan(out),isempty(out)])
            error('castInputField:dataFormatIssue',...
                'There is a formating problem with the %s field on a(n) %s entry.',fieldName,entryName)
        end
        if mod(out,1)~=0
            error('castInputField:fieldShouldBeInteger',...
                'The %s field on a(n) %s entry should be an integer.',fieldName,entryName);
        end
        if out < intmin(dataType) || out > intmax(dataType)
            error('castInputField:fieldValueOutsideIntegerRange',...
            'The %s field on a(n) %s entry has a value of %d, which is outside the range of values that can be stored using type %s.',fieldName,entryName,out,dataType);
        end
        out = cast(out,dataType);
    otherwise
        error('castInputField:dataTypeNotSupported',...
            'dataType %s not supported by castInputField() function.',dataType)
end

%% Check output values are within specified range
if isnumeric(out)
    if nargin > 5
        if ~isempty(dataMin)
            if out < dataMin
                error('castInputField:fieldValueOutsideSpecifiedRange',...
                    'The %s field on a(n) %s entry should be greater than or equal to %g',fieldName,entryName,dataMin);
            end
        end
    end
    if nargin > 6
        if out > dataMax
            error('castInputField:fieldValueOutsideSpecifiedRange',...
                  'The %s field on a(n) %s entry should be less than or equal to %g',fieldName,entryName,dataMax);
        end
    end
end