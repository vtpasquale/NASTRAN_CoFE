% Class for MAT1 entries
% Anthony Ricciardi
%
classdef mat1 < entry
    
    % entry data
    properties
        MID
        E
        G
        NU
        RHO
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function MAT1 = initialize(data)
            MAT1 = mat1;
            MAT1.MID = set_data('MAT1','MID',data{2},'int',[],1);
            MAT1.E = set_data('MAT1','E',data{3},'dec',[]);
            MAT1.G = set_data('MAT1','G',data{4},'dec',-999);
            MAT1.NU = set_data('MAT1','NU',data{5},'dec',-999);
            MAT1.RHO = set_data('MAT1','RHO',data{6},'dec',0.0);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function mat = entry2model(obj)
            mat = [];
        end
		% Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'MAT1,%d,%f,%f,%f,%f\n',obj.MID,obj.E,obj.G,obj.NU,obj.RHO);
        end
    end
end

