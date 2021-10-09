% Class for point moment vectors.
% Anthony Ricciardi
%
classdef Moment < Load
    
    properties
        sid % [uint32] Load set identification number.
        g % [uint32] Grid point identification number.
        cid % [uint32] Coordinate system identification number.
        m % [3,1 double] Moment vector expressed in coordinate system defined by CID.
    end
    methods
        function [p_g,gdof]=assemble_sub(obj,model)
            % Outputs
            % gdof [1,3 uint32] index of global degrees of freedom
            % p_g [3,1 double] moment vector expressed in the nodal displacement coordinate system defined at grid points.
            fnode = model.point.getNode(obj.g,model);
            fcsys = model.coordinateSystem.getCoordinateSystem(obj.cid,model);
            gdof = fnode.gdof(4:6);
            p_g = fnode.T_g0*...
                  fcsys.T_c0(fcsys.x_c(fnode.x_0)).'*...
                  obj.m;
        end
    end
end
