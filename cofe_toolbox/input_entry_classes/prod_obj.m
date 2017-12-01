% Class for PROD property entries
% Anthony Ricciardi
%
classdef prod_obj < entry
    
    properties
        PID % Property identification number. (Integer > 0)
        MID % Material identification number. (Integer > 0)
        A % Area of the rod. (Real)
        J % Torsional constant. (Real)
        C % Coefficient to determine torsional stress. (Real; Default = 0.0)
        NSM % Nonstructural mass per unit length. (Real)
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function PROD = initialize(data)
            PROD = prod_obj;
            PROD.PID = set_data('PROD','PID',data{2},'int',NaN,1);
            PROD.MID = set_data('PROD','MID',data{3},'int',NaN,1);
            PROD.A = set_data('PROD','A',data{4},'dec',NaN);
            PROD.J = set_data('PROD','J',data{5},'dec',NaN);
            PROD.C = set_data('PROD','C',data{6},'dec',[],0.0);
            PROD.NSM = set_data('PROD','NSM',data{7},'dec',0.0);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function MODEL = entry2model(obj,MODEL)
            P_ROD = p_rod;
            P_ROD.PID = obj.PID;
            P_ROD.MID = obj.MID;
            P_ROD.A = obj.A;
            P_ROD.J = obj.J;
            P_ROD.NSM = obj.NSM;
            MODEL.PROP = [MODEL.PROP;P_ROD];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'PROD,%d,%d,%f,%f,,%f\n',obj.PID,obj.MID,obj.A,obj.J,obj.NSM);
        end
    end
end

