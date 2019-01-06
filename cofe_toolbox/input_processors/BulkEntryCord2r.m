% Defines a rectangular coordinate system using the coordinates of three points.
% Anthony Ricciardi
%
classdef BulkEntryCord2r < Cord2
    
    properties
        cid % (uint32 > 0) Coordinate system identification number. 
        rid % (uint32 >= 0) Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        a % ([3,1] double) Coordinates of point a in coordinate system rid.
        b % ([3,1] double) Coordinates of point b in coordinate system rid. 
        c % ([3,1] double) Coordinates of point c in coordinate system rid.
    end
    methods
        function bulkEntryCord2r = BulkEntryCord2r(entryFields) 
            % Construct using entry field data input as cell array of char 
            bulkEntryCord2r=constructCord2(bulkEntryCord2r,entryFields);
        end
        function model = entry2model_sub(obj,model)
            % Convert entry object to model object and store in model entity array
            cord = Cordr;
            cord.cid = obj.cid;
            cord.rid = obj.rid;
            cord.a = obj.a;
            cord.b = obj.b;
            cord.c = obj.c;
            model.cord = [model.cord;cord];
        end
        function echo_sub(obj,fid)
            % Print the entry in NASTRAN free field format to a text file
            fprintf(fid,'CORD2R,%d,%d,%f,%f,%f,%f,%f,%f\n',obj.cid,obj.rid,obj.a',obj.b');
            fprintf(fid,',%f,%f,%f\n',obj.c');
        end
        
    end
end