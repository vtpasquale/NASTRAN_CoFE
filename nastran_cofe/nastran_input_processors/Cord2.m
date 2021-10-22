% Helper superclass for defining coordinate systems using the coordinates of three points.
% Anthony Ricciardi
%
classdef (Abstract) Cord2 < BulkEntry
    
    properties (Abstract)
        cid % (uint32 > 0) Coordinate system identification number. 
        rid % (uint32 >= 0) Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        a % ([3,1] double) Coordinates of point a in coordinate system rid.
        b % ([3,1] double) Coordinates of point b in coordinate system rid. 
        c % ([3,1] double) Coordinates of point c in coordinate system rid.
    end
    
    methods (Hidden=true)
        function obj = constructCord2(obj,entryFields)
            % Construct using entry field data input as cell array of char  
            obj.cid = castInputField('CORD2x','CID',entryFields{2},'uint32',NaN,1);
            obj.rid = castInputField('CORD2x','RID',entryFields{3},'uint32',uint32(0),0);
            obj.a = zeros(3,1);
            obj.b = zeros(3,1);
            obj.c = zeros(3,1);
            obj.a(1) = castInputField('CORD2x','A1',entryFields{4},'double',NaN);
            obj.a(2) = castInputField('CORD2x','A2',entryFields{5},'double',NaN);
            obj.a(3) = castInputField('CORD2x','A3',entryFields{6},'double',NaN);
            obj.b(1) = castInputField('CORD2x','B1',entryFields{7},'double',NaN);
            obj.b(2) = castInputField('CORD2x','B2',entryFields{8},'double',NaN);
            obj.b(3) = castInputField('CORD2x','B3',entryFields{9},'double',NaN);
            obj.c(1) = castInputField('CORD2x','C1',entryFields{12},'double',NaN);
            obj.c(2) = castInputField('CORD2x','C2',entryFields{13},'double',NaN);
            obj.c(3) = castInputField('CORD2x','C3',entryFields{14},'double',NaN);
        end
    end
end