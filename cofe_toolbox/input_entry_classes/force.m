% Class for PROD property entries
% Anthony Ricciardi
%
classdef force < entry
    
    properties
        SID % Load set identification number. (Integer > 0)
        G % Grid point identification number. (Integer > 0)
        CID % Coordinate system identification number. (Integer > 0; Default = 0)
        F % Scale factor. (Real)
        N1 % Components of a vector measured in coordinate system defined by CID. (Real; at least one Ni ~= 0.0. unless F is zero)
        N2
        N3
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function FORCE = initialize(data)
            FORCE = force;
            FORCE.SID = set_data('FORCE','SID',data{2},'int',NaN,1);
            FORCE.G = set_data('FORCE','G',data{3},'int',NaN,1);
            FORCE.CID = set_data('FORCE','CID',data{4},'int',0);            
            FORCE.F = set_data('FORCE','F',data{5},'dec',NaN);
            FORCE.N1 = set_data('FORCE','N1',data{6},'dec',0.0);
            FORCE.N2 = set_data('FORCE','N2',data{7},'dec',0.0);
            FORCE.N3 = set_data('FORCE','N3',data{8},'dec',0.0);
            if FORCE.F ~= 0 && all([FORCE.N1,FORCE.N2,FORCE.N3]==0)
                error('Error with FORCE CID=%d: at least one Ni ~= 0.0. Unless F is zero.',FORCE.SID)
            end
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function FORCE = entry2model(obj)
            FORCE = [];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'FORCE,%d,%d,%d,%f,%f,%f,%f\n',obj.SID,obj.G,obj.CID,obj.F,obj.N1,obj.N2,obj.N3);
        end
    end
end

