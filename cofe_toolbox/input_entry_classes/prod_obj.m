% Class for PROD property entries
% Anthony Ricciardi
%
classdef prod_obj < entry
    
    % entry data
    properties
        PID
        MID
        A
        J
        NSM
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function PROD = initialize(data)
            PROD = prod_obj;
            PROD.PID = set_data('PROD','PID',data{2},'int',[],1);
            PROD.MID = set_data('PROD','MID',data{3},'int',[] ,1);
            PROD.A = set_data('PROD','A',data{4},'dec',[]);
            PROD.J = set_data('PROD','J',data{5},'dec',[]);
            PROD.NSM = set_data('PROD','NSM',data{7},'dec',0.0);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function p_rod = entry2model(obj)
            p_rod = [];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'PROD,%d,%d,%f,%f,,%f\n',obj.PID,obj.MID,obj.A,obj.J,obj.NSM);
        end
    end
end

