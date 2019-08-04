% Class for ASET1 entries
% Anthony Ricciardi
%
classdef BulkEntryAset1 < BulkEntry & BulkSet1
    
%% Inherited from BulkSet1
%     properties
%         c % [:,1 uint32] Component numbers. Zero OR a sequential combination of integers 1 thru 6.
%         i1 % [n,1 uint32] list of individual identification numbers and the first identification number for any THRU ranges
%         iN % [n,1 uint32] list of the second identification number for any THRU ranges
%         thru % [n,1 logical] true where i1(thru,1) and iN(thru,1) contain THRU ranges
%     end
%     properties (Hidden = true)
%         ENTRY_NAME
%         DOFSET_NAME
%     end

%% Constructor method
    methods
        function obj = BulkEntryAset1(entryFields)
            % Construct using entry field data input as cell array of char
            
            % Intended to be constant properties - traditional constant 
            % properteis not allowed with class structure
            obj.ENTRY_NAME = 'ASET1';
            obj.DOFSET_NAME = 'a';
            
            % Construct using BulkSet1 method
            obj = obj.construct(entryFields);
        end
    end
    
%% Inherited from BulkSet1
%     methods
%         function obj = construct(obj,entryFields)
%         function model = entry2model_sub(obj,model)
%         function echo_sub(obj,fid)
%     end
end
