% Class for SPCFORCES Case Control entries
% Anthony Ricciardi
%
classdef CaseEntrySpcforces < CaseEntry & CaseEntryOutpuRequest
    
    properties
        outputRequest=OutputRequest % [OutputRequest]
    end
    methods
        function obj = CaseEntrySpcforces(entryFields)
            obj = obj.processDescribers(entryFields);
        end
        function caseControl = entry2CaseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.spcforces = obj.outputRequest;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
            obj.echoOutputRequest(fid,'SPCFORCES')
        end
    end
    
    
end
