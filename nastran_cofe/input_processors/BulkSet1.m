% Helper superclass for Bulk Data xSET1 entries (e.g, ASET1, BSET1, etc.)
% Anthony Ricciardi
%
classdef (Abstract) BulkSet1 < IntegerList
    
    properties
        c % [:,1 uint32] Component numbers. Zero OR a sequential combination of integers 1 thru 6.
        i1 % [n,1 uint32] list of individual identification numbers and the first identification number for any THRU ranges
        iN % [n,1 uint32] list of the second identification number for any THRU ranges
        thru % [n,1 logical] true where i1(thru,1) and iN(thru,1) contain THRU ranges
    end
    properties (Hidden = true)
        ENTRY_NAME
        DOFSET_NAME
    end
    methods
        function obj = construct(obj,entryFields)
            % Construct using entry field data input as cell array of char
            obj.c = castInputField(obj.ENTRY_NAME,'C',entryFields{2},'uint32',uint32(0),0,123456);
            obj.c = expandComponents(obj.c,sprintf('%s C',obj.ENTRY_NAME),true);
            obj = obj.readIntegerFields(entryFields(3:end),obj.ENTRY_NAME); % Method Inherited from IntegerList
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            values = obj.getValues(); % Method Inherited from IntegerList
            model.dofSet=[model.dofSet;DofSet(obj.DOFSET_NAME,obj.c,values)];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            obj.echoIntegerFields(fid,[obj.ENTRY_NAME,',',sprintf('%d',obj.c),',']) % Method Inherited from IntegerList
        end
    end
end
