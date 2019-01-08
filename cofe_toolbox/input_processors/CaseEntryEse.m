% Class for ESE Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryEse < CaseEntry & CaseEntryOutpuRequest
    
    properties
        outputRequest=OutputRequest % [OutputRequest]
    end
    methods
        function obj = CaseEntryEse(entryFields)
            obj = obj.processDescribers(entryFields);
        end
        function caseControl = entry2CaseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.ese = obj.outputRequest;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            obj.echoOutputRequest(fid,'ESE')
        end
    end
    
    
end
