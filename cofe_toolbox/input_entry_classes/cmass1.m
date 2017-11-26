% Class for CMASS1 entries
% Anthony Ricciardi
%
classdef cmass1 < entry
    
    properties
        EID % Unique element identification number. (0 < Integer < 100,000,000)
        PID % Property identification number of a PMASS entry. (Integer > 0; Default = EID)
        G1 % Grid identification number. (Integer > 0)
        C1 % Component numbers. (0 < Integer < 6)
        G2 % Grid identification number. (Integer > 0)
        C2 % Component numbers. (0 < Integer < 6)
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function CMASS1 = initialize(data)
            CMASS1=cmass1;
            CMASS1.EID = set_data('CMASS1','EID',data{2},'int',NaN,1,100000000);
            CMASS1.PID = set_data('CMASS1','PID',data{3},'int',NaN,1);
            CMASS1.G1 = set_data('CMASS1','G1',data{4},'int',NaN,1);
            CMASS1.C1 = set_data('CMASS1','C1',data{5},'int',NaN,1,6);
            CMASS1.G2 = set_data('CMASS1','G2',data{6},'int',[],1);
            CMASS1.C2 = set_data('CMASS1','C2',data{7},'int',[],1,6);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function c_mass = entry2model(obj)
            c_mass = [];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'CMASS1,%d,%d,%d,%d,%d,%d\n',obj.EID,obj.PID,obj.G1,obj.C1,obj.G2,obj.C2);
        end
        
    end
end
