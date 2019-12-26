% Class for FORCE Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryForce < CaseEntry & CaseEntryOutpuRequest
    
    properties
        outputRequest=OutputRequest % [OutputRequest]
    end
    methods
        function obj = CaseEntryForce(entryFields)
            obj = obj.processDescribers(entryFields);
        end
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.force = obj.outputRequest;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            obj.echoOutputRequest(fid,'FORCE')
        end
    end
    
    
end
