% Helper superclass for defining coordinate systems using the coordinates of three points.
% Anthony Ricciardi
%
classdef (Abstract) cord2 < entry
    
    properties (Abstract)
        CID % (Integer > 0) Coordinate system identification number. 
        RID % (Integer > 0; Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        A % ([3,1] Float) Coordinates of point A in coordinate system RID.
        B % ([3,1] Float) Coordinates of point B in coordinate system RID. 
        C % ([3,1] Float) Coordinates of point C in coordinate system RID.
    end
    
    methods (Hidden=true)
        function obj = initialize_cord2(obj,data)
            % Initialize property values based on bulk data inputs
            obj.CID = set_data('CORD2R','CID',data{2},'int',NaN,1);
            obj.RID = set_data('CORD2R','RID',data{3},'int',0,0);
            obj.A = zeros(3,1);
            obj.B = zeros(3,1);
            obj.C = zeros(3,1);
            obj.A(1) = set_data('CORD2R','A1',data{4},'dec',NaN);
            obj.A(2) = set_data('CORD2R','A2',data{5},'dec',NaN);
            obj.A(3) = set_data('CORD2R','A3',data{6},'dec',NaN);
            obj.B(1) = set_data('CORD2R','B1',data{7},'dec',NaN);
            obj.B(2) = set_data('CORD2R','B2',data{8},'dec',NaN);
            obj.B(3) = set_data('CORD2R','B3',data{9},'dec',NaN);
            obj.C(1) = set_data('CORD2R','C1',data{12},'dec',NaN);
            obj.C(2) = set_data('CORD2R','C2',data{13},'dec',NaN);
            obj.C(3) = set_data('CORD2R','C3',data{14},'dec',NaN);
        end
    end
end