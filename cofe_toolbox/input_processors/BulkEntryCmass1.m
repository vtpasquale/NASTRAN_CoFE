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
        function MODEL = entry2model_sub(obj,MODEL)
            % Write appropriate model object(s) based on entry data
            C_MASS1 = c_mass1;
            C_MASS1.EID = obj.EID;
            C_MASS1.PID = obj.PID;
            C_MASS1.G = obj.G1;
            C_MASS1.C = obj.C1;
            if ~isempty(obj.G2)
                error('Nonblank G2 on CMASS1 EID = %d. Nonblank G2 is not supported.',C_MASS1.EID)
            end
            MODEL.ELEM = [MODEL.ELEM;C_MASS1];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'CMASS1,%d,%d,%d,%d,%d,%d\n',obj.eid,obj.pid,obj.g1,obj.c1,obj.g2,obj.c2);
        end
        
    end
end
