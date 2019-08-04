% Class for SUBCASE Case Control entries
% Anthony Ricciardi
%
classdef CaseEntrySubcase < CaseEntry
    
    properties
        ID % [uint32] Subcase identification number.
    end
    methods
        function obj = CaseEntrySubcase(entryFields)
            obj.ID = castInputField('SUBCASE','RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
        end
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control Object
            caseControl.subcase = obj.ID;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            fprintf(fid,'SUBCASE = %d\n',obj.ID);
        end
    end
    
    
end
