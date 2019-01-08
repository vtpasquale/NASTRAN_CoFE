% Class for LOAD Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryLoad < CaseEntry
    
    properties
        n % [int32]
    end
    methods
        function obj = CaseEntryLoad(entryFields)
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                error('Format issue with LOAD Case Control entry.')
            end
            % Process right-hand-side describers
            obj.n = castInputField('Case Control LOAD Entry',...
                'RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
        end % CaseEntryLoad()
        function caseControl = entry2CaseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.load = obj.n;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            fprintf(fid,'LOAD = %d\n',obj.n);
        end
    end
end