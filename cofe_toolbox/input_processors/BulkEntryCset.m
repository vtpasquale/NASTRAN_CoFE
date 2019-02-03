% Class for CSET entries
% Anthony Ricciardi
%
classdef BulkEntryCset < BulkEntry & BulkSet
    
%% Inherited from BulkSet
%     properties
%         id1 % [uint32] Grid or scalar point identification number.
%         c1 % [:,1 uint32] Component numbers. Zero OR a sequential combination of integers 1 thru 6.
%         id2 % [uint32]
%         c2 % [:,1 uint32] 
%         id3 % [uint32]
%         c3 % [:,1 uint32]
%         id4 % [uint32]
%         c4 % [:,1 uint32]
%     end
%     properties (Hidden = true)
%         ENTRY_NAME
%         DOFSET_NAME
%     end

%% Constructor method
    methods
        function obj = BulkEntryCset(entryFields)
            % Construct using entry field data input as cell array of char
            
            % Intended to be constant properties - traditional constant 
            % properteis not allowed with class structure
            obj.ENTRY_NAME = 'CSET';
            obj.DOFSET_NAME = 'c';
            
            % Construct using BulkSet method
            obj = obj.construct(entryFields);
        end
    end
    
%% Inherited from BulkSet
%     methods
%         function obj = construct(obj,entryFields)
%         function model = entry2model_sub(obj,model)
%         function echo_sub(obj,fid)
%     end
end
