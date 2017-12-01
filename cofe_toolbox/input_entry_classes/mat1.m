% Class for MAT1 entries
% Anthony Ricciardi
%
classdef mat1 < entry
    properties
        MID % Material identification number. (Integer > 0)
        E % Young’s modulus. (Real > 0.0 or blank)
        G % Shear modulus. (Real > 0.0 or blank)
        NU % Poisson’s ratio. See Remark 14. (-1.0 < Real < 0.5 or blank)
        RHO % Mass density. (Real)
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function MAT1 = initialize(data)
            MAT1 = mat1;
            MAT1.MID = set_data('MAT1','MID',data{2},'int',NaN);
            MAT1.E = set_data('MAT1','E',data{3},'dec',[]);
            MAT1.G = set_data('MAT1','G',data{4},'dec',[]);
            MAT1.NU = set_data('MAT1','NU',data{5},'dec',[],-1.0,0.5);
            seg = size([MAT1.E,MAT1.G],2);
            if seg<1
                error('Error with MAT1 MID = %d: E and G may not both be blank.',MAT1.MID)
            elseif seg<2 && isempty(MAT1.NU)
                error('Error with MAT1 MID = %d: NU must be defined if either E or G is blank.',MAT1.MID)
            end
            MAT1.RHO = set_data('MAT1','RHO',data{6},'dec',0.0);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function MODEL = entry2model(obj,MODEL)
            MAT_1 = mat_1;
            MAT_1.MID = obj.MID;
            seg = size([obj.E,obj.G],2);
            if seg<1
                error('Error with MAT1 MID = %d: E and G may not both be blank.',obj.MID)
            elseif seg<2 && isempty(obj.NU)
                error('Error with MAT1 MID = %d: NU must be defined if either E or G is blank.',obj.MID)
            elseif seg==1
                if isempty(obj.G)
                    obj.G=obj.E/(2*(1+obj.NU));
                else % isempty(obj.E) 
                    obj.E=obj.G*2*(1+obj.NU);
                end
            end
            MAT_1.E = obj.E;
            MAT_1.G = obj.G;
            MAT_1.NU = obj.NU;
            MAT_1.RHO = obj.RHO;
            MODEL.MAT=[MODEL.MAT;MAT_1];
        end
		% Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'MAT1,%d,%f,%f,%f,%f\n',obj.MID,obj.E,obj.G,obj.NU,obj.RHO);
        end
    end
end

