% Class for GRID entries
% Anthony Ricciardi
%
classdef grid_obj < entry
    
    properties
        ID
        CP
        X1
        X2
        X3
        CD
        PS
        SEID
    end
        methods (Static = true)
            % Initialize entry properties based on input file entry data in cell format
            function GRID = initialize(data)
                GRID = grid_obj;
                GRID.ID = set_data('GRID','ID',data{2},'int',[],1,100000000);
                GRID.CP = set_data('GRID','CP',data{3},'int',0 ,0);
                % if obj.CP ~= 0; error('Nonzero GRID CP not supported.'); end
                GRID.X1 = set_data('GRID','X1',data{4},'dec',[]);
                GRID.X2 = set_data('GRID','X2',data{5},'dec',[]);
                GRID.X3 = set_data('GRID','X3',data{6},'dec',[]);
                GRID.CD = set_data('GRID','CD',data{7},'int',0);
                if GRID.CD ~= 0; error('Nonzero GRID CD not supported.'); end
                GRID.PS = set_data('GRID','PS',data{8},'int',-999); % set to -999 if blank
                GRID.SEID = set_data('GRID','SEID',data{9},'int',0);
                if GRID.SEID ~= 0; error('Nonzero GRID SEID not supported.'); end
            end
        end
        methods
            % Write appropriate model object(s) based on entry data
            function node = entry2model(obj)
                node = [];
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

