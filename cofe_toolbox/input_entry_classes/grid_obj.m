% Class for GRID entries
% Anthony Ricciardi
%
classdef grid_obj < entry
    
    properties
        ID % Grid point identification number. (0 < Integer < 100,000,000)
        CP % Identification number of coordinate system in which the location of the grid point is defined. (Integer >= 0 or blank*)
        X1 % Location of the grid point in coordinate system CP. (Real; Default = 0.0)
        X2 % Location of the grid point in coordinate system CP. (Real; Default = 0.0)
        X3 % Location of the grid point in coordinate system CP. (Real; Default = 0.0)
        CD % Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the grid point. (Integer > 0 or blank*)
        PS % Permanent single-point constraints associated with the grid point. (Any of the Integers 1 through 6 with no embedded blanks, or blank*.)
        SEID % Superelement identification number. (Integer > 0; Default = 0)
        % *See the GRDSET entry for default options for the CP, CD, PS, and SEID fields.
    end
    methods (Static = true)
        % Initialize entry properties based on input file entry data in cell format
        function GRID = initialize(data)
            GRID = grid_obj;
            GRID.ID = set_data('GRID','ID',data{2},'int',NaN,1,100000000);
            GRID.CP = set_data('GRID','CP',data{3},'int',[] ,0);
            GRID.X1 = set_data('GRID','X1',data{4},'dec',0.0);
            GRID.X2 = set_data('GRID','X2',data{5},'dec',0.0);
            GRID.X3 = set_data('GRID','X3',data{6},'dec',0.0);
            GRID.CD = set_data('GRID','CD',data{7},'int',[] ,0);
            GRID.PS = set_data('GRID','PS',data{8},'int',[]);
            GRID.SEID = set_data('GRID','SEID',data{9},'int',[]);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function MODEL = entry2model(obj,MODEL)
            if ~(obj.SEID == 0 | isempty(obj.SEID)); error('GRID ID = %d had a nonzero SEID, which is not supported.',obj.ID); end
            NODE = node;
            NODE.ID=uint32(obj.ID);
            NODE.CP=obj.CP;
            NODE.X_P = [obj.X1; obj.X2; obj.X3];
            NODE.CD=obj.CD;
            ps = [false;false;false;false;false;false;false];
            if ~isempty(obj.PS)
                ps(7)=true; % explicitly define perminate single point constraints (overides defaults)
                if obj.PS ~= 0
                    ind = str2num(num2str(obj.PS)');
                    if any(ind>6) || any(ind<1)
                        error('There is a formatting problem with the PS field in GRID ID = %d.',obj.ID)
                    end
                    ps(ind)=true;
                end
            end
            NODE.PS=ps;
            MODEL.NODE=[MODEL.NODE;NODE];
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            if obj.PS == -999
                fprintf(fid,'GRID,%d,%d,%f,%f,%f,%d\n',obj.ID,obj.CP,obj.X1,obj.X2,obj.X3,obj.CD);
            else
                fprintf(fid,'GRID,%d,%d,%f,%f,%f,%d,%d\n',obj.ID,obj.CP,obj.X1,obj.X2,obj.X3,obj.CD,obj.PS);
            end
        end
        
    end
end

