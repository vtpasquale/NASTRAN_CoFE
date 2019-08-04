% Class for point force vectors.
% Anthony Ricciardi
%
classdef Force < Load
    
    properties
        sid % [uint32] Load set identification number.
        g % [uint32] Grid point identification number.
        cid % [uint32] Coordinate system identification number.
        f % [3,1 double] Force vector expressed in coordinate system defined by CID.
        
        gdof % [1,3 uint32] index of global degrees of freedom 
        p_g % [3,1 double] Force vector expressed in the nodal displacement coordinate system defined at grind point g.
    end
    methods
        function obj=preprocess_sub(obj,model)
            fnode = model.point.getNode(obj.g,model);
            fcsys = model.coordinateSystem.getCoordinateSystem(obj.cid,model);
            obj.gdof = fnode.gdof(1:3);
            obj.p_g = fnode.T_g0*...
                      fcsys.T_c0(fcsys.x_c(fnode.x_0)).'*...
                      obj.f;
        end
    end
end
