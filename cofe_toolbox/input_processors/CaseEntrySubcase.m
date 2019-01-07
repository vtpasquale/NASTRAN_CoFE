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
        function caseControl = entry2CaseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control Object
            caseControl.ID = obj.ID;
        end
    end
    
    
end
