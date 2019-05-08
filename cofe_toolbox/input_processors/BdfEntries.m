% Container & interface class for CaseEntry and BulkEntry classes
% Interfaces with BdfFields and Model classes
%
% Anthony Ricciardi
%
classdef BdfEntries
    properties
        caseEntry % [nCaseEntries,1 CaseEntry] Array of input file case entries
        bulkEntry % {nSuperElements,1 [nBulkEntries,1 BulkEntry]} Array of input file bulk data entries
    end
    properties (Hidden = true)
        sol; % [char] Describer of the first SOL entry in the executive control section
        superElementID % [nSuperElements, 1 uint32] Superelement ID number
    end
    methods
        function obj = BdfEntries(bdfFields)
            obj.sol = bdfFields.sol;
            obj.superElementID = bdfFields.superElementID;
            obj.caseEntry = CaseEntry.constructFromFields(bdfFields.caseControl);
            obj.bulkEntry = BulkEntry.constructFromFields(bdfFields.bulkData);
        end
        function model = entries2model(obj)
            % Case control data as provided in input file
            caseControl = obj.caseEntry.entry2caseControl(obj.sol);
            
            % Create Model superelements from bulk data
            model = BulkEntry.entry2model(obj.bulkEntry,obj.superElementID);
            
            % Save case control data to applicable Model superelements 
            model = caseControl.caseControl2model(model,obj.superElementID);
        end
    end
end