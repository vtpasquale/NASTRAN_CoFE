% Class for CMASS1 entries
% Anthony Ricciardi
%
classdef BulkEntryCmass1 < BulkEntry
    
    properties
        eid % Unique element identification number. (1 <= uint32 <= 4,294,967,295)
        pid % Property identification number of a PMASS entry. (1 <= uint32 <= 4,294,967,295; Default = EID)
        g1 % Grid identification number. (1 <= uint32 <= 4,294,967,295)
        c1 % Component numbers. (1 <= uint8 <= 6)
        g2 % Grid identification number. (1 <= uint32 <= 4,294,967,295)
        c2 % Component numbers. (1 <= uint8 <= 6)
    end
    
    methods
        function obj = BulkEntryCmass1(entryFields)
            % Construct using entry field data input as cell array of char
            obj.eid = castInputField('CMASS1','EID',entryFields{2},'uint32',NaN,1);
            obj.pid = castInputField('CMASS1','PID',entryFields{3},'uint32',NaN,1);
            obj.g1 = castInputField('CMASS1','G1',entryFields{4},'uint32',NaN,1);
            obj.c1 = castInputField('CMASS1','C1',entryFields{5},'uint8',NaN,1,6);
            obj.g2 = castInputField('CMASS1','G2',entryFields{6},'uint32',[],1);
            obj.c2 = castInputField('CMASS1','C2',entryFields{7},'uint8',[],1,6);
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            cmass1 = Cmass1;
            cmass1.eid = obj.eid;
            cmass1.pid = obj.pid;
            cmass1.g = obj.g1;
            cmass1.c = obj.c1;
            if ~isempty(obj.g2)
                error('Nonblank G2 on CMASS1 EID = %d. Nonblank G2 is not supported.',cmass1.eid)
            end
            model.element = [model.element;cmass1];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'CMASS1,%d,%d,%d,%d,%d,%d\n',obj.eid,obj.pid,obj.g1,obj.c1,obj.g2,obj.c2);
        end
        
    end
end
