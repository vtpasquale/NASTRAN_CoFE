% Abstract superclass for Case Control output request entries
% Anthony Ricciardi
%
classdef (Abstract) CaseEntryOutpuRequest
    
    properties  (Abstract)
        outputRequest % [OutputRequest]
    end
    methods (Sealed = true)
        function obj = processDescribers(obj,entryFields)
            
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                lhDescribers = upper(strtrim(strsplit(entryFields.leftHandDescribers,',')));
                
                printListed = any(strcmp('PRINT',lhDescribers));
                plotListed = any(strcmp('PLOT',lhDescribers));
                
                if printListed && plotListed
                    error('Case control output requests both PRINT and PLOT options, but only one can be selected.')
                elseif plotListed
                    obj.outputRequest.print = false;
                end
            end
            
            % Process right-hand-side describers
            if isempty(entryFields.rightHandDescribers)
                error('Missing right hand describers for Case Control entry.')
            else
                switch strtrim(upper(entryFields.rightHandDescribers))
                    case 'NONE'
                        % obj.outputRequest.n = 0; Default
                    case 'ALL'
                        obj.outputRequest.n = -1;
                    otherwise
                        obj.outputRequest.n = castInputField('Case Control Output Request',...
                            'RightHandSideDescriber',entryFields.rightHandDescribers,'uint32',NaN,1);
                end
            end
        end % processDescribers()
        function echoOutputRequest(obj,fid,entryName)
            switch obj.outputRequest.n
                case -1
                    rhs = 'ALL';
                case 0
                    rhs = 'NONE';
                otherwise
                    rhs = num2str(obj.outputRequest.n);
            end
            if obj.outputRequest.print
                lhs = 'PRINT';
            else
                lhs = 'POST';
            end
            fprintf(fid,'%s(%s)=%s\n',entryName,lhs,rhs);
        end % echoOutputRequest()
    end
end
