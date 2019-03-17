% Class for SUPER Case Control entries
% Anthony Ricciardi
%
classdef CaseEntrySuper < CaseEntry
    
    properties
        id % [int32] Number to reference superelement IDs 
           %   -1 -> The subcase is assigned to all 
           %         superelements and all loading conditions.
           %
           %    n (>= 0) -> Superelement identification number
           %                OR Set identification number of a 
           %                previously appearing SET command. 
           %                The subcase is assigned to all 
           %                superelements with identification 
           %                numbers that appear on this SET 
           %                command. (The  SET identification 
           %                number must be unique with  respect 
           %                to any superelement identification 
           %                numbers. In addition, the same sets
           %                must be used for all loading 
           %                conditions)
           %
        el % [uint32] Load sequence number
    end
    methods
        function obj = CaseEntrySuper(entryFields)
            % Process left-hand-side describers
            if ~isempty(entryFields.leftHandDescribers)
                error('Case control SUPER input should have no left-hand-side describers.')
            end
            % Process right-hand-side describers
            if isempty(entryFields.rightHandDescribers)
                error('Missing right hand describers for Case Control entry.')
            else
                rightHandSide = strtrim(entryFields.rightHandDescribers);
                if strcmpi(rightHandSide,'ALL')
                    obj.id = int32(-1);
                else
                    splitRightHandSide = strtrim(strsplit(rightHandSide,','));
                    switch size(splitRightHandSide,2)
                        case 1
                            idUint32 = castInputField('Case Control Output Request',...
                            'RightHandSideDescriber',splitRightHandSide,'uint32',NaN,0);
                            obj.id = int32(idUint32);
                        case 2
                            idUint32 = castInputField('Case Control Output Request',...
                            'RightHandSideDescriber',splitRightHandSide{1},'uint32',NaN,0);
                            obj.id = int32(idUint32);
                            obj.el = castInputField('Case Control Output Request',...
                            'RightHandSideDescriber',splitRightHandSide{2},'uint32',NaN,1);
                        otherwise
                            error('Format issue with case control SUPER entry')
                    end
                end
            end
        end
        function caseControl = entry2caseControl_sub(obj,caseControl)
            % Convert Case Control entry to property in Case Control Object
            caseControl.superelement = obj.id;
            caseControl.loadSequence = obj.el;
        end
        function echo_sub(obj,fid)
            % Print the case control entry in NASTRAN format to a text file with file id fid
              switch obj.id
                case -1
                    rhs = 'ALL';
                otherwise
                    rhs = num2str(obj.id);
                    if ~isempty(obj.el)
                        rhs = [rhs,', ',num2str(obj.el)]
                    end
              end
            fprintf(fid,'SUPER = %s\n',rhs);
        end
    end
end
