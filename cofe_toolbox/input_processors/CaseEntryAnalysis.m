% Class for ANALYSIS Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryAnalysis < CaseEntry
    
    properties
        type % [char] e.g.: STATICS, MODES, BUCK
    end
    methods
        function obj = CaseEntryAnalysis(entryFields)
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                error('Left Hand Side Describers not supported for ANALYSIS Case Control entry.')
            end
            % Process right-hand-side describers
            obj.type = castInputField('Case Control ANALYSIS Entry',...
                'RightHandSideDescriber',entryFields.rightHandDescribers,'char',NaN);
        end % CaseEntryLoad()
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.analysis = obj.type;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            fprintf(fid,'ANALYSIS = %d\n',obj.type);
        end
    end
end