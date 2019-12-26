% Helper superclass for Bulk Data xSET entries (e.g, ASET, BSET, etc.)
% Anthony Ricciardi
%
classdef (Abstract) BulkSet
    
    properties
        id1 % [uint32] Grid or scalar point identification number.
        c1 % [:,1 uint32] Component numbers. Zero OR a sequential combination of integers 1 thru 6.
        id2 % [uint32]
        c2 % [:,1 uint32] 
        id3 % [uint32]
        c3 % [:,1 uint32]
        id4 % [uint32]
        c4 % [:,1 uint32]
    end
    properties (Hidden = true)
        ENTRY_NAME
        DOFSET_NAME
    end
    methods
        function obj = construct(obj,entryFields)
            % Construct using entry field data input as cell array of char
            obj.id1 = castInputField(obj.ENTRY_NAME,'ID1',entryFields{2},'uint32',NaN,0);
            obj.c1  = castInputField(obj.ENTRY_NAME,'C1', entryFields{3},'uint32',uint32(0),0,123456);
            obj.c1  = expandComponents(obj.c1,sprintf('%s C1',obj.ENTRY_NAME),true);
            
            if ~isempty(entryFields{4})
                obj.id2 = castInputField(obj.ENTRY_NAME,'ID2',entryFields{4},'uint32',NaN,0);
                obj.c2  = castInputField(obj.ENTRY_NAME,'C2', entryFields{5},'uint32',uint32(0),0,123456);
                obj.c2  = expandComponents(obj.c2,sprintf('%s C2',obj.ENTRY_NAME),true);
                
                if ~isempty(entryFields{6})
                    obj.id3 = castInputField(obj.ENTRY_NAME,'ID3',entryFields{6},'uint32',NaN,0);
                    obj.c3  = castInputField(obj.ENTRY_NAME,'C3', entryFields{7},'uint32',uint32(0),0,123456);
                    obj.c3  = expandComponents(obj.c3,sprintf('%s C3',obj.ENTRY_NAME),true);
                    
                    if ~isempty(entryFields{8})
                        obj.id4 = castInputField(obj.ENTRY_NAME,'ID4',entryFields{8},'uint32',NaN,0);
                        obj.c4  = castInputField(obj.ENTRY_NAME,'C4', entryFields{9},'uint32',NaN,0,123456);
                        obj.c4  = expandComponents(obj.c4,sprintf('%s C4',obj.ENTRY_NAME),true);
                    end
                end
            end
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            if ~isempty(obj.id4)
                newDofset = [...
                    DofSet(obj.DOFSET_NAME,obj.c1,obj.id1);
                    DofSet(obj.DOFSET_NAME,obj.c2,obj.id2);
                    DofSet(obj.DOFSET_NAME,obj.c3,obj.id3);
                    DofSet(obj.DOFSET_NAME,obj.c4,obj.id4)];
            elseif ~isempty(obj.id3)
                newDofset = [...
                    DofSet(obj.DOFSET_NAME,obj.c1,obj.id1);
                    DofSet(obj.DOFSET_NAME,obj.c2,obj.id2);
                    DofSet(obj.DOFSET_NAME,obj.c3,obj.id3)];
            elseif ~isempty(obj.id2)
                newDofset = [...
                    DofSet(obj.DOFSET_NAME,obj.c1,obj.id1);
                    DofSet(obj.DOFSET_NAME,obj.c2,obj.id2)];
            else
                newDofset = DofSet(obj.DOFSET_NAME,obj.c1,obj.id1);
            end
            model.dofSet=[model.dofSet;newDofset];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            
            if ~isempty(obj.id4)
                fprintf(fid,'%s,%d,%s,%d,%s,%d,%s,%d,%s\n',obj.ENTRY_NAME,...
                    obj.id1,num2str(obj.c1)',...
                    obj.id2,num2str(obj.c2)',...
                    obj.id3,num2str(obj.c3)',...
                    obj.id4,num2str(obj.c4)');
                
            elseif ~isempty(obj.id3)
                fprintf(fid,'%s,%d,%s,%d,%s,%d,%s\n',obj.ENTRY_NAME,...
                    obj.id1,num2str(obj.c1)',...
                    obj.id2,num2str(obj.c2)',...
                    obj.id3,num2str(obj.c3)');
                
            elseif ~isempty(obj.id2)
                fprintf(fid,'%s,%d,%s,%d,%s\n',obj.ENTRY_NAME,...
                    obj.id1,num2str(obj.c1)',...
                    obj.id2,num2str(obj.c2)');
            else
                fprintf(fid,'%s,%d,%s\n',obj.ENTRY_NAME,...
                    obj.id1,num2str(obj.c1)');
            end
        end % echo_sub()
    end
end
