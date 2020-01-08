% Class for MDLPRM entries
% Initial implementation is not intended to be functional other than to
% aviod file processing errors with input files that contain MDLPRM.
% Anthony Ricciardi
%
classdef BulkEntryMdlprm < BulkEntry
    
    properties
        param1 % [char] Parameter name
        val1 % [char] Parameter value
    end
    
    methods
        function obj = BulkEntryMdlprm(entryFields)
            % Construct using entry field data input as cell array of char
            obj.param1  = castInputField('MDLPRM','PARAM1',entryFields{2},'char',NaN);
            obj.val1 = castInputField('MDLPRM','VAL1',entryFields{3},'char',NaN);
            if ~strcmp(entryFields{4},'')
                error('Onle one MDLPRM parameter supported per entry. This can be expanded - see BulkEntrySpc1 for example.')
            end
        end
        function model = entry2model_sub(obj,model)
            % Not converted 
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'MDLPRM,%s,%s\n',obj.param1,obj.val1);
        end
    end
end

