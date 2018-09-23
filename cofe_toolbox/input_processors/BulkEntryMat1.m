% Class for MAT1 entries
% Anthony Ricciardi
%
classdef BulkEntryMat1 < BulkEntry
    properties
        mid % Material identification number. (Integer > 0)
        E % Young’s modulus. (Real > 0.0 or blank)
        G % Shear modulus. (Real > 0.0 or blank)
        nu % Poisson’s ratio. See Remark 14. (-1.0 < Real < 0.5 or blank)
        rho % Mass density. (Real)
    end
    
    methods
        function obj = BulkEntryMat1(entryFields)
            % Construct using entry field data input as cell array of char
            obj.mid = castInputField('MAT1','MID',entryFields{2},'uint32',NaN);
            obj.E = castInputField('MAT1','E',entryFields{3},'double',[]);
            obj.G = castInputField('MAT1','G',entryFields{4},'double',[]);
            obj.nu = castInputField('MAT1','NU',entryFields{5},'double',[],-1.0,0.5);
            seg = size([obj.E,obj.G],2);
            if seg<1
                error('Error with MAT1 MID = %d: E and G may not both be blank.',obj.mid)
            elseif seg<2 && isempty(obj.nu)
                error('Error with MAT1 MID = %d: NU must be defined if either E or G is blank.',obj.mid)
            end
            obj.rho = castInputField('MAT1','RHO',entryFields{6},'double',0.0);
        end
        % Write appropriate model object(s) based on entry data
        function MODEL = entry2model_sub(obj,MODEL)
            MAT_1 = mat_1;
            MAT_1.mid = obj.mid;
            seg = size([obj.E,obj.G],2);
            if seg<1
                error('Error with MAT1 MID = %d: E and G may not both be blank.',obj.mid)
            elseif seg<2 && isempty(obj.nu)
                error('Error with MAT1 MID = %d: NU must be defined if either E or G is blank.',obj.mid)
            elseif seg==1
                if isempty(obj.G)
                    obj.G=obj.E/(2*(1+obj.nu));
                else % isempty(obj.E) 
                    obj.E=obj.G*2*(1+obj.nu);
                end
            end
            MAT_1.E = obj.E;
            MAT_1.G = obj.G;
            MAT_1.nu = obj.nu;
            MAT_1.rho = obj.rho;
            MODEL.MAT=[MODEL.MAT;MAT_1];
        end
		% Print the entry in NASTRAN free field format to a text file with file id fid
        function echo_sub(obj,fid)
            fprintf(fid,'MAT1,%d,%f,%f,%f,%f\n',obj.mid,obj.E,obj.G,obj.nu,obj.rho);
        end
    end
end

