% Class for DISPLACEMENT Case Control entries
% Anthony Ricciardi
%
classdef CaseEntryDisplacement < CaseEntry
    
    properties
        outputRequest=OutputRequest % [OutputRequest]
    end
    methods
        function obj = CaseEntryDisplacement(entryFields)
            
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                lhDescribers = upper(strtrim(strsplit(entryFields.leftHandDescribers,',')));
                if any(strcmp('PRINT',lhDescribers))
                    obj.outputRequest.print = true;
                end
                if any(strcmp('PLOT',lhDescribers))
                    obj.outputRequest.plot = true;
                end
            end
            
            % Process right-hand-side describers
            if isempty(entryFields.rightHandDescribers)
                error('Missing right hand describers for Case Control entry.')
            else
                switch upper(entryFields.rightHandDescribers)
                    case 'NONE'
                        % obj.outputRequest.n = 0; Default
                    case 'ALL'
                        obj.outputRequest.n = -1;
                    otherwise
                        obj.outputRequest.n = castInputField('DISPLACEMENT','RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
                end
            end
        end
        function caseControl = entry2CaseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control
            caseControl.displacement = obj.outputRequest;
        end
    end
    
    
end
