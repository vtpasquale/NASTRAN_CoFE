% Class for STATSUB Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryStatsub < CaseEntry
    
    properties
        n % [int32]
    end
    methods
        function obj = CaseEntryStatsub(entryFields)
            % Ignore left-hand-side describers

            % Process right-hand-side describers
            obj.n = castInputField('Case Control STATSUB Entry',...
                'RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
        end % CaseEntryLoad()
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.statsub = obj.n;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            fprintf(fid,'STATSUB = %d\n',obj.n);
        end
    end
end