% Class for DISPLACEMENT Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryDisplacement < CaseEntry & CaseEntryOutpuRequest
    
    properties
        outputRequest=OutputRequest % [OutputRequest]
    end
    methods
        function obj = CaseEntryDisplacement(entryFields)
            obj = obj.processDescribers(entryFields);
        end
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.displacement = obj.outputRequest;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            obj.echoOutputRequest(fid,'DISPLACEMENT')
        end
    end
    
    
end
