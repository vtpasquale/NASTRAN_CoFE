% Return checked input field data cast to requested type from field data input as [char]
% Anthony Ricciardi
%
% Inputs
% entryName [string] entry name, used for potential error messages
% fieldName [string] field name, used for potential error messages
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
% dataMin:    [real] minimum value - optional - only used for numeric types
% dataMax:    [real] maximum value - optional - only used for numeric types
%
% Outputs
% out [dataType] checked input field data cast to specified dataType
%
function out = setData(entryName,fieldName,fieldData,dataType,dataDefault,dataMin,datMax)

%% check for empty field
if strcmp(fieldData,'');
    if isnan(dataDefault)
        error(['The ',fieldName,' field is required for ',entryName,' entries.'])
    elseif isempty(dataDefault)
        out = dataDefault;
        return
    else
        fieldData = dataDefault;
        if ~isa(fieldData,dataType)
            error('If a default field value is specified, class(default) should match the class specified by the "dataType" input.')
        end
    end
end
    
%% Check and cast output
switch dataType
    case 'char'
        out = fieldData;
        if ~ischar(out)
            error(['The ',fieldName,' field on ',entryName,' entries should be type char.']);
        end
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
                error('There is a formating problem')
            end
        end
        
        out = sscanf(fieldData,'%f'); % out = str2double(data);
        if ~isa(out,'double')
            error([fieldName,' on  ',entryName,' should be type double.']);
        end
    case {'uint8','uint32'}
        out = sscanf(fieldData,'%f'); % out = str2double(data);
        if mod(out,1)~=0
            error([fieldName,' field on ',entryName,' entry should be an integer.']);
        end
        if out < intmin(dataType) || out > intmax(dataType)
            error('The %s field on a(n) %s entry has a value of %d, which is outside the range of values that can be stored using type %s.',fieldName,entryName,out,dataType);
        end
        out = cast(out,dataType);
    otherwise
        error('dataType %s not supported by setData() function.',dataType)
end
        
%% Check out values are within specified range
if isnumeric(out)
    if nargin > 5
        if out < dataMin
            error([fieldName,' field on ',entryName,' should be greater than or equal to ',num2str(dataMin),'.']);
        end
    end
    if nargin > 6
        if out > datMax
            error([fieldName,' field on ',entryName,' should be less than or equal to ',num2str(datMax),'.']);
        end
    end
end