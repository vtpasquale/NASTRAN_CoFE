% Check primitive input data and return data in proper format
% Anthony Ricciardi
%
% Inputs
% entryName[string] entry name, for error messages
% fieldName[string] field name, for error messages
% data:    [string] raw field data
% type:    [string] data type.
%             'str' for string
%             'int' for integer
%             'dec' for real
%
% default: [type] default value, will enforce data is defined if not empty.
%                   Set to [] if input is required.
% min:     [real] minimum value - optional - only used for reals
% max:     [real] maximum value - optional - only used for reals
%
% Outputs
% out: [type] formatted field data
%
function out = set_data(entryName,fieldName,data,type,default,min,max)

%% check for empty field
if strcmp(data,'');
    if isempty(default)
        error([fieldName,' is required for ',entryName,' entries.'])
    end
    if strcmp(type,'str')
        data = default;
    else
        data = sprintf('%f',default); % data = num2str(default);
    end
end
    
%% assign output
switch type
    case 'str'
        out = data;
        if ischar(out) == 0
            error([fieldName,' field on ',entryName,' entry should be a string.']);
        end
    case 'int'
        out = sscanf(data, '%f'); % out = str2double(data);
        if mod(out,1) ~= 0
            error([fieldName,' field on ',entryName,' entry should be an integer.']);
        end
        out = int32(out);
        if isinteger(out) == 0
            error([fieldName,' field on ',entryName,' entry should be an integer.']);
        end
        
    case 'dec'
                
        % deal with scientific notation
        sign = strfind(data(2:end),'-');
        if isempty(sign) 
            sign = strfind(data(2:end),'+');
        end
        if isempty(sign) ~= 1
            E = strfind(upper(data(2:end)),'E');
            if isempty(E)
                dataNew = [data,' '];
                dataNew(sign+2:end) = data(sign+1:end);
                dataNew(sign+1)='E';
                data = dataNew;
            elseif sign-E ~= 1
                error('There is a formating problem')
            end
        end
        
        out = sscanf(data, '%f'); % out = str2double(data);
        if isfloat(out) == 0
            error([fieldName,' on  ',entryName,' should be a real number.']);
        end
end
        
%% Check values
if strcmp(type,'int') || strcmp(type,'dec')
    if nargin > 5
        if out < min
            error([fieldName,' field on ',entryName,' should be greater than or equal to',num2str(min),'.']);
        end
    end
    if nargin > 6
        if out > max
            error([fieldName,' field on ',entryName,' should be less than or equal to',num2str(max),'.']);
        end
    end
end