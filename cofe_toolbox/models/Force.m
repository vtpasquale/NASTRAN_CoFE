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
        function obj=preprocess_sub(obj,model)
            gIndex = obj.g==model.nodeIDs;
            cIndex = obj.cid==model.coordinateSystemCIDs;
            obj.gdof = model.node2gdof(1:3,gIndex);
            
            fnode = model.node(gIndex);
            fcsys = model.coordinateSystem(cIndex);
            
            obj.p_g = fnode.T_g0*...
                      fcsys.T_c0(fcsys.x_c(fnode.x_0)).'*...
                      obj.f;
        end
    end
end
