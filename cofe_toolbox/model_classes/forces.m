% Class for point force vectors.
% Anthony Ricciardi
%
classdef forces < loads
    
    properties
        SID % [int] Load set identification number.
        G % [int] Grid point identification number.
        CID % [int] Coordinate system identification number.
        F % [3,1 real] Force vector expressed in coordinate system defined by CID.
        
        gdof
        p % [3,1 real] Force vector expressed in the nodal displacement coordinate system defined at grind point G.
    end
    methods
        function obj=assemble(obj,MODEL)
            gind = obj.G==MODEL.nodeIDs;
            cind = obj.CID==MODEL.cordCIDs;
            obj.gdof = MODEL.node2gdof(1:3,gind);
            
            fnode = MODEL.NODE(gind);
            fcord = MODEL.CORD(cind);
            
            obj.p = fnode.T_G0*...
                    fcord.T_C0(fcord.X_C(fnode.X_0)).'*...
                    obj.F;
        end
    end
end
