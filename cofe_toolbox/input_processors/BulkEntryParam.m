% Class for PARAM entries
% Anthony Ricciardi
%
classdef BulkEntryParam < BulkEntry
    
    properties
        n % [char] Parameter name
        v1 % [char] Parameter value based on parameter type
        v2 % [char] Parameter value based on parameter type
    end
        methods (Static = true)
            function obj = BulkEntryParam(entryFields)
            % Construct using entry field data input as cell array of char
                obj.n  = castInputField('PARAM','N',entryFields{2},'char',NaN);
                obj.v1 = castInputField('PARAM','V1',entryFields{3},'char',NaN);
                obj.v2 = castInputField('PARAM','V2',entryFields{4},'char',[]);
            end
        end
        methods
            function model = entry2model_sub(obj,model)
                % Convert entry object to model object and store in model entity array
                if isempty(model.param)
                    model.param = {obj.n,obj.v1,obj.v2};
                else
                    nParam = size(model.param,1);
                    model.param{nParam+1,1} = obj.n;
                    model.param{nParam+1,2} = obj.v1;
                    model.param{nParam+1,3} = obj.v2;
                end
            end
            function echo_sub(obj,fid)
                % Print the entry in NASTRAN free field format to a text file with file id fid
                if isempty(obj.v2)
                    fprintf(fid,'PARAM,%s,%s\n',obj.n,obj.v1);
                else
                    fprintf(fid,'PARAM,%s,%s,%s\n',obj.n,obj.v1,obj.v2);
                end
            end
            
        end
end