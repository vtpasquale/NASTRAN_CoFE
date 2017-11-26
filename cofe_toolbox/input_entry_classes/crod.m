% Class for CROD entry, a tension-compression-torsion element.
% Anthony Ricciardi
%
classdef crod < entry
    
    properties
        EID % Element identification number. (0 < Integer < 100,000,000)
        PID % Property identification number of a PROD entry. (Integer > 0; Default = EID)
        G1 % Grid point identification numbers of connection points. (Integer > 0; G1 ~= G2 )
        G2
    end
    methods (Static = true)
        function CROD = initialize(data)
            CROD=crod;
            CROD.EID = set_data('CROD','EID',data{2},'int',NaN,1,100000000);
            CROD.PID = set_data('CROD','PID',data{3},'int',CROD.EID,1);
            CROD.G1 = set_data('CROD','G1',data{4},'dec',NaN,1);
            CROD.G2 = set_data('CROD','G2',data{5},'dec',NaN,1);
            if CROD.G1 == CROD.G2
                error('G1 and G2 fields must be unique on CROD entries.')
            end
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
            function MODEL = entry2model(obj,MODEL)
                C_ROD = c_rod;

            end
		% Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'CROD,%d,%d,%d,%d\n',obj.EID,obj.PID,obj.G1,obj.G2);
        end
    end

    
end
