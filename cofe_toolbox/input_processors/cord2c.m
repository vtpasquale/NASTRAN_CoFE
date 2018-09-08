% Defines a cylindrical coordinate system using the coordinates of three points.
% Anthony Ricciardi
%
classdef cord2c < cord2
    
    properties
        CID % (Integer > 0) Coordinate system identification number. 
        RID % (Integer > 0; Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        A % ([3,1] Float) Coordinates of point A in coordinate system RID.
        B % ([3,1] Float) Coordinates of point B in coordinate system RID. 
        C % ([3,1] Float) Coordinates of point C in coordinate system RID.
    end
    
    methods (Static=true)   
        function CORD2C = initialize(data) 
            % Initialize entry properties based on input file entry data in cell format 
            CORD2C=cord2c;
            CORD2C=CORD2C.initialize_cord2(data);
        end
    end
    methods
        function MODEL = entry2model(obj,MODEL)
            % Write appropriate model object(s) based on entry data
            CORD = cordc;
            CORD.CID = obj.CID;
            CORD.RID = obj.RID;
            CORD.A = obj.A;
            CORD.B = obj.B;
            CORD.C = obj.C;
            MODEL.CORD = [MODEL.CORD;CORD];
        end
        function echo(obj,fid)
		    % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'CORD2C,%d,%d,%f,%f,%f,%f,%f,%f\n',obj.CID,obj.RID,obj.A',obj.B');
            fprintf(fid,',%f,%f,%f\n',obj.C');
        end
        
    end
end