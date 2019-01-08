% Class for SPC Case Control entries
% Anthony Ricciardi
%
classdef CaseEntrySpc < CaseEntry
    
    properties
        n % [int32]
    end
    methods
        function obj = CaseEntrySpc(entryFields)
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                error('Format issue with SPC Case Control entry.')
            end
            % Process right-hand-side describers
            obj.n = castInputField('Case Control SPC Entry',...
                'RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
        end % CaseEntryLoad()
        function caseControl = entry2CaseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.spc = obj.n;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            fprintf(fid,'SPC = %d\n',obj.n);
        end
    end
end