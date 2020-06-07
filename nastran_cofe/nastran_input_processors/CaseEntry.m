% Abstract superclass for Nastran Case Control input entries
% Anthony Ricciardi
%
classdef (Abstract) CaseEntry < matlab.mixin.Heterogeneous
    methods (Abstract)
        % The class constructor must initialize entry properties using entry field data input as struct array of char 
        
        % Print the entry in NASTRAN free field format to a text file with file id fid
        echo_sub(obj,fid)
        
        % Convert entry object to model object and store in model entity array
        caseControl = entry2caseControl_sub(obj,caseControl)
    end
    
    methods (Sealed = true)
        function caseControl = entry2caseControl(obj,sol)
                        
            % process sol input
            if isempty(sol)
                warning('Default solution undefined. Statics is assumed default.')
                sol = 101;
            end
            switch upper(sol)
                case {101,'101','STATICS','SESTATICS'}
                    defaultAnalysis = 'STATICS';
                case {103,'103','MODES','SEMODES'}
                    defaultAnalysis = 'MODES';
                case {105,'105','BUCK','SEBUCK'}
                    defaultAnalysis = 'BUCK';
                otherwise
                    error('SOL type %s not supported.',num2str(sol))
            end
            
            % Convert case control entry array to CaseControl objects
            [n,m]=size(obj);
            if m > 1; error('CaseEntry.entry2CaseControl(fid) can only handle nx1 arrays of CaseEntry objects. The second dimension exceeds 1.'); end
            
            % Master case
            masterCaseControl = CaseControl;
            masterCaseControl.subcase = uint32(1);
            masterCaseControl.analysis = defaultAnalysis;
            i = 1;
            while i<=n
                if isa(obj(i),'CaseEntrySubcase')
                    break
                end
                masterCaseControl = entry2caseControl_sub(obj(i),masterCaseControl);
                i = i+1;
            end
            if i<=n
                % Specific subcases
                subcaseIndex = 1;
                caseControl(subcaseIndex,1)=masterCaseControl;
                caseControl(subcaseIndex,1) = entry2caseControl_sub(obj(i),caseControl(subcaseIndex,1));
                i = i+1;
                while i<=n
                    if isa(obj(i),'CaseEntrySubcase')
                        subcaseIndex = subcaseIndex + 1;
                        caseControl(subcaseIndex,1) = masterCaseControl;
                    end
                    caseControl(subcaseIndex,1) = entry2caseControl_sub(obj(i),caseControl(subcaseIndex,1));
                    i = i+1;
                end
            else
                caseControl=masterCaseControl;
            end
        end % entry2CaseControl(obj)
        function echo(obj,fid)
            % Execute CaseEntry.echo_sub(fid) for all heterogeneous CaseEntry objects in array
            [n,m]=size(obj);
            if m > 1; error('CaseEntry.echo(fid) can only handle nx1 arrays of CaseEntry objects. The second dimension exceeds 1.'); end
            for i=1:n
                echo_sub(obj(i),fid);
            end
        end % echo()
    end
    methods (Sealed = true, Static = true)
        
        function caseEntry = constructFromFields(caseControlFields)
            % construct case entry objectes from input fields
            iKeep = 1;
            for i = 1:size(caseControlFields,1)
                fields = caseControlFields{i};
                % convert field 1 to case-sensitive class name
                entryName =  lower(fields.entryName);
                entryName(1) = upper(entryName(1));
                % check that input entry is supported
                if exist(['CaseEntry',entryName],'class')==8
                    % Call contructor method for each entry
                    eval(['caseEntry(iKeep,1) = CaseEntry',entryName,'(fields);']);
                    iKeep = iKeep + 1;
                else
                    warning('Case control entry %s not supported. Entry skipped.',upper(entryName))
                end
            end
            % create a default case entry if undefined
            if ~exist('caseEntry','var')
                entryFields.leftHandDescribers = [];
                entryFields.rightHandDescribers = 'STATICS';
                caseEntry = CaseEntryAnalysis(entryFields);
            end
        end % constructFromFields()
    end
end
