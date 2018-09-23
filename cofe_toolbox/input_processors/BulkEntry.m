% Abstract superclass for Nastran Bulk Data input entries
% Anthony Ricciardi
%
classdef (Abstract) BulkEntry < matlab.mixin.Heterogeneous
    methods (Abstract)
        % The class constructor must initialize entry properties using entry field data input as cell array of char 
        
        % Print the entry in NASTRAN free field format to a text file with file id fid
        echo_sub(obj,fid)
        
        % Write appropriate model object(s) based on entry data
        model = entry2model_sub(obj)
    end
    
    methods (Sealed = true)
        % Execute entry.echo_sub(fid) for all heterogeneous entry objects in array
        function echo(obj,fid)
            [n,m]=size(obj);
            if m > 1; error('entry.echo_all(fid) can only handle nx1 arrays of entry objects. The second dimension exceeds 1.'); end
            for i=1:n
                echo_sub(obj(i),fid);
            end
        end
        % Execute entry.entry2model_sub(fid) for all heterogeneous entry objects in array
        function MODEL = entry2model(obj)
            [n,m]=size(obj);
            if m > 1; error('entry.entry2model_all(fid) can only handle nx1 arrays of entry objects. The second dimension exceeds 1.'); end
            MODEL = model;
            for i = 1:n
                MODEL = entry2model_sub(obj(i),MODEL);
            end
        end
    end
    methods (Sealed = true, Static = true)
        % Read input file and create heterogeneous entry array from input data
        function bulkEntry = constructFromFields(bulkDataFields)
            for i = 1:size(bulkDataFields,1)
                fields = bulkDataFields{i};
                % convert field 1 to case-sensitive class name
                entryName =  lower(fields{1});
                entryName(1) = upper(entryName(1));
                if strcmp(entryName(end),'*');
                    entryName = entryName(1:end-1);
                end
                % check that input entry is supported
                if exist(['BulkEntry',entryName],'class')==8
                    % Call contructor method for each entry
                    eval(['bulkEntry(i,1) = BulkEntry',entryName,'(fields);']);
                else
                    error('Bulk data entry %s not supported.',upper(entryName))
                end
            end
        end % importBulkEntry()
    end
end
