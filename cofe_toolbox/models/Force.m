% Class for point force vectors.
% Anthony Ricciardi
%
classdef Force < Load
    
    properties
        sid % [int] Load set identification number.
        g % [int] Grid point identification number.
        cid % [int] Coordinate system identification number.
        f % [3,1 real] Force vector expressed in coordinate system defined by CID.
        
        gdof
        p_g % [3,1 real] Force vector expressed in the nodal displacement coordinate system defined at grind point G.
    end
    methods
        function obj=preprocess_sub(obj,MODEL)
            gind = obj.g==MODEL.nodeIDs;
            cind = obj.cid==MODEL.cordCIDs;
            obj.gdof = MODEL.node2gdof(1:3,gind);
            
            fnode = MODEL.NODE(gind);
            fcord = MODEL.CORD(cind);
            
            obj.p_g = fnode.T_G0*...
                      fcord.T_C0(fcord.X_C(fnode.X_0)).'*...
                      obj.f;
        end
    end
end
