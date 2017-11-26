% Class for GRDSET entry, which defines default options for fields 3, 7, 8, and 9 of all GRID entries.
% Anthony Ricciardi
%
classdef grdset < entry
    
    properties
        CP % Identification number of coordinate system in which the location of the grid points are defined. (Integer >= 0 or blank)
        CD % Identification number of coordinate system in which the displacements, degrees of freedom, constraints, and solution vectors of the grid point are defined. (Integer >= 0 or blank)
        PS % Permanent single-point constraints on the grid point. (Any combination of Integers 1 through 6 with no embedded blanks, or blank.)
        SEID % Superelement identification number. (Integer > 0 or blank)
    end
    
    methods (Static = true)
		% Initialize entry properties based on input file entry data in cell format
        function GRDSET = initialize(data)
            GRDSET=grdset;
            GRDSET.CP = set_data('GRDSET','CP',data{3},'int',[],0);
            GRDSET.CD = set_data('GRDSET','CD',data{7},'int',[],0);
            GRDSET.PS = set_data('GRDSET','PS',data{8},'int',[]);
            GRDSET.SEID = set_data('GRDSET','SEID',data{9},'int',[]);
        end
    end
    methods
        % Write appropriate model object(s) based on entry data
        function MODEL = entry2model(obj,MODEL)
            ps = [false;false;false;false;false;false];
            if ~isempty(obj.PS)
                ps(str2num(num2str(obj.PS)'))=true;
            end
            MODEL.NODE.setgetGRDSET(obj.CP,obj.CD,ps);
        end
        % Print the entry in NASTRAN free field format to a text file with file id fid
        function echo(obj,fid)
            fprintf(fid,'GRDSET,,%d,,,,%d,%d\n',obj.CP,obj.CD,obj.PS);
        end
        
    end
end
