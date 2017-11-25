% Defines a rectangular coordinate system using the coordinates of three points.
% Anthony Ricciardi
%
classdef cord2r < cordr & cord2
    
    properties
        CID % (Integer > 0) Coordinate system identification number. 
        RID % (Integer > 0; Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        A % ([3,1] Float) Coordinates of point A in coordinate system RID.
        B % ([3,1] Float) Coordinates of point B in coordinate system RID. 
        C % ([3,1] Float) Coordinates of point C in coordinate system RID.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
        TC_C0 % ([3,3] Symmetric Float) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    
    methods        
        %% Inherits from cord2
        % function obj = initialize(obj,data) % Initialize entry properties based on input file entry data in cell format 
        % function obj = preprocess(obj,Robj) % Preprocess coordinate system
        
        function echo(obj,fid)
            % Print the entry in NASTRAN free field format to a text file with file id fid
            fprintf(fid,'CORD2R,%d,%d,%f,%f,%f,%f,%f,%f\n',obj.CID,obj.RID,obj.A',obj.B');
            fprintf(fid,',%f,%f,%f\n',obj.C');
        end
        
    end
end