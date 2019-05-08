% Abstract superclass for Nastran Bulk Data input entries
% Anthony Ricciardi
%
classdef (Abstract) BulkEntry < matlab.mixin.Heterogeneous
    methods (Abstract)
        % The class constructor must initialize entry properties using entry field data input as cell array of char 
        
        % Print the entry in NASTRAN free field format to a text file with file id fid
        echo_sub(obj,fid)
        
        % Convert entry object to model object and store in model entity array
        model = entry2model_sub(obj,model)
    end
    
    methods (Sealed = true)
        function echo(obj,fid)
            % Execute entry.echo_sub(fid) for all heterogeneous entry objects in array
            [n,m]=size(obj);
            if m > 1; error('BulkEntry.echo(fid) can only handle nx1 arrays of entry objects. The second dimension exceeds 1.'); end
            for i=1:n
                echo_sub(obj(i),fid);
            end
        end
    end
    methods (Sealed = true, Static = true)
        function bulkEntry = constructFromFields(bulkDataFields)
            if ~iscell(bulkDataFields); error('Input bulkDataFields should be type cell'); end
            % Read input fields and create heterogeneous entry array from input data
            nSuperElements = size(bulkDataFields,1);
            for i = 1:nSuperElements
                bulkEntry{i,1} = BulkEntry.constructFromFields_sub(bulkDataFields{i});
            end
        end % constructFromFields()
        function bulkEntry = constructFromFields_sub(bulkDataFields)
            % Read input fields and create heterogeneous entry array from input data
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
        end % constructFromFields_sub()
        function model = entry2model(bulkEntry,superElementID)
            % Convert bulk data entry object array to model object entity arrays
            [nSuperElements,mSuperElements]=size(bulkEntry);
            if mSuperElements > 1; error('BulkEntry.entry2model(bulkEntry) can only handle nx1 cell arrays of BulkEntry arrays. The second dimension exceeds 1.'); end
            model = [];
            for i = 1:nSuperElements
                modelI = Model;
                modelI.superElementID = superElementID(i);
                bulkEntryI = bulkEntry{i};
                [nEntries,mEntries]=size(bulkEntryI);
                if mEntries ~= 1; error('bulkEntry cell array contains a BulkEntry array with size(BulkEntry,2)~=1'); end
                for j = 1:nEntries
                    modelI = entry2model_sub(bulkEntryI(j),modelI);
                end
                model = [model;modelI];
            end
        end
    end
end
