% Abstract superclass for input entries
% Anthony Ricciardi
%
classdef (Abstract) entry < matlab.mixin.Heterogeneous
    properties (Constant = true, GetAccess = private)
       matlab_entry_conflict_names =  {'grid','load','prod'}; % Cell array of strings with supported input entry names that conflict with MATLAB names. These entry class names are appended with '_obj' to deconflict.
    end
    methods (Abstract)
        % Initialize entry properties based on input file entry data in cell format 
        initialize(obj,data)
        
        % Print the entry in NASTRAN free field format to a text file with file id fid
        echo(obj,fid)
        
        % Write appropriate model object(s) based on entry data
        model = entry2model(obj)
    end
    
    methods (Sealed = true)        
        % Execute entry.echo(fid) for all heterogeneous entry objects in array
        function echo_all(obj,fid)
            [n,m]=size(obj);
            if m > 1; error('entry.echo_all(fid) can only handle nx1 arrays of entry objects. The second dimension exceeds 1.'); end
            for i=1:n
                echo(obj(i),fid);
            end
        end
        % Execute entry.entry2model(fid) for all heterogeneous entry objects in array
        function MODEL = entry2model_all(obj)
            [n,m]=size(obj);
            if m > 1; error('entry.entry2model_all(fid) can only handle nx1 arrays of entry objects. The second dimension exceeds 1.'); end
            MODEL = model;
            for i=1:n
                MODEL = entry2model(obj(i),MODEL);
            end
        end
    end
    methods (Sealed = true, Static = true)
        % Read input file and create heterogeneous entry array from input data
        function ENTRY = import_entries(filename)
            data = import_data('grids.bdf');
            nData = size(data,2);
            for i = 1:nData
                fields = data(i).fields;
                entryName =  lower(fields{1});
                % special treatment for entry names that overlap with MATLAB built-in function names
                if any(strcmp(entryName,entry.matlab_entry_conflict_names))
                    entryName = [entryName,'_obj'];
                end
                % check that input entry is supported
                eval(['isaEntry = isa(',entryName,',''entry'');']);
                if isaEntry
                    % Call initialize method for each entry
                    eval(['ENTRY(i,1) = ',entryName,'.initialize(fields);']);
                else
                    error('Entry type %s not supported.',upper(entryName))
                end
            end
        end
    end
    
end

