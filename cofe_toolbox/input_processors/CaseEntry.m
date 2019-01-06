% Abstract superclass for Nastran Case Control input entries
% Anthony Ricciardi
%
classdef (Abstract) CaseEntry < matlab.mixin.Heterogeneous
    methods (Abstract)
        % The class constructor must initialize entry properties using entry field data input as struct array of char 
        
        % Print the entry in NASTRAN free field format to a text file with file id fid
        echo_sub(obj,fid)
        
        % Convert entry object to model object and store in model entity array
        caseControl = entry2CaseControl_sub(obj,caseControl)
    end
    
    methods (Sealed = true)
        % Execute entry.echo_sub(fid) for all heterogeneous entry objects in array
        function echo(obj,fid)
            [n,m]=size(obj);
            if m > 1; error('CaseEntry.echo(fid) can only handle nx1 arrays of entry objects. The second dimension exceeds 1.'); end
            for i=1:n
                echo_sub(obj(i),fid);
            end
        end
        function caseControl = entry2CaseControl(obj)
            % Convert case control entry array to CaseControl objects
            [n,m]=size(obj);
            if m > 1; error('CaseEntry.entry2CaseControl(fid) can only handle nx1 arrays of CaseEntry objects. The second dimension exceeds 1.'); end
            caseControl = CaseControl;
            for i = 1:n
                caseControl = entry2CaseControl_sub(obj(i),caseControl);
            end
        end
    end
    methods (Sealed = true, Static = true)
        
        function caseEntry = constructFromFields(caseControlFields)
            % construct case entry objectes from input fields
            for i = 1:size(caseControlFields,1)
                fields = caseControlFields{i};
                % convert field 1 to case-sensitive class name
                entryName =  lower(fields.entryName);
                entryName(1) = upper(entryName(1));
                % check that input entry is supported
                if exist(['CaseEntry',entryName],'class')==8
                    % Call contructor method for each entry
                    eval(['caseEntry(i,1) = CaseEntry',entryName,'(fields);']);
                else
                    warning('Case control entry %s not supported. Entry skipped.',upper(entryName))
                end
            end
        end % constructFromFields()
    end
end
