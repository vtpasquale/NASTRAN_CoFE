% Class for METHOD Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryMethod < CaseEntry
    
    properties
        n % [int32]
    end
    methods
        function obj = CaseEntryMethod(entryFields)
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                error('Left Hand Side Describers not supported for METHOD Case Control entry.')
            end
            % Process right-hand-side describers
            obj.n = castInputField('Case Control METHOD Entry',...
                'RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
        end % CaseEntryLoad()
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.method = obj.n;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            fprintf(fid,'METHOD = %d\n',obj.n);
        end
    end
end