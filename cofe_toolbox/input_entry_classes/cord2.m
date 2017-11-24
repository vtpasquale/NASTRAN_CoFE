% Helper superclass for defining coordinate systems using the coordinates of three points.
% Anthony Ricciardi
%
classdef (Abstract) cord2
    
    properties (Abstract)
        CID % (Integer > 0) Coordinate system identification number. 
        RID % (Integer > 0; Default = 0; which is the basic coordinate system.) Identification number of a coordinate system that is defined independently from this coordinate system. 
        A % ([3,1] Float) Coordinates of point A in coordinate system RID.
        B % ([3,1] Float) Coordinates of point B in coordinate system RID. 
        C % ([3,1] Float) Coordinates of point C in coordinate system RID.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
        TC_C0 % ([3,3] Symmetric Float) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    
    methods
        function obj = initialize(obj,data)
            % Initialize property values based on bulk data inputs
            obj.CID = set_data('CORD2R','CID',data{2},'int',[],1);
            obj.RID = set_data('CORD2R','RID',data{3},'int',0,0);
            obj.A = zeros(3,1);
            obj.B = zeros(3,1);
            obj.C = zeros(3,1);
            obj.A(1) = set_data('CORD2R','A1',data{4},'dec',[]);
            obj.A(2) = set_data('CORD2R','A2',data{5},'dec',[]);
            obj.A(3) = set_data('CORD2R','A3',data{6},'dec',[]);
            obj.B(1) = set_data('CORD2R','B1',data{7},'dec',[]);
            obj.B(2) = set_data('CORD2R','B2',data{8},'dec',[]);
            obj.B(3) = set_data('CORD2R','B3',data{9},'dec',[]);
            obj.C(1) = set_data('CORD2R','C1',data{12},'dec',[]);
            obj.C(2) = set_data('CORD2R','C2',data{13},'dec',[]);
            obj.C(3) = set_data('CORD2R','C3',data{14},'dec',[]);
        end
        function obj = preprocess(obj,Robj)
            % Preprocess coordinate system
            dAB = obj.B-obj.A;
            nu = (obj.C-obj.A);
            
            if (dAB < 1e5*eps) | (nu < 1e5*eps)
                error(['Coordinate system CID = ',num2str(obj.CID),'has coincident or close to coincident points.']);
            end
            
            z = dAB./norm_cs(dAB);
            y = cross3(z,nu); y = y./norm(y);
            x = cross3(y,z); x = x./norm(x);
            T_CR = [x,y,z];
            
            obj.TC_C0 = T_CR*Robj.TC_C0;
            obj.XC_0 = Robj.XC_0 + Robj.TC_C0.'*obj.A;
        end
    end
end