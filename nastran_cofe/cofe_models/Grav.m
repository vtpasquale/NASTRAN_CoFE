% Class for gravity vectors.
% Anthony Ricciardi
%
classdef Grav < Load
    
    properties
        sid % [uint32] Load set identification number.
        cid % [uint32] Coordinate system identification number.
        a % [3,1 double] Acceleration vector expressed in coordinate system defined by CID.
    end
    methods
        function [p_g,gdof]=assemble_sub(obj,model)
            % Outputs
            % gdof [1,n uint32] index of global degrees of freedom
            % p_g [n,1 double] Force vector expressed in the nodal displacement coordinate system defined at grid points.
            fcsys = model.coordinateSystem.getCoordinateSystem(obj.cid,model);
            if ~isa(fcsys,'Cordr')
                error('Gravity entries should reference a rectangular coordinate system - avoid spherical or cylindrical coordinate systems.')
            end
            a_0 = fcsys.T_c0(fcsys.x_c(fcsys.xc_0)).'* obj.a;
            
            % Create acceleration vector
            a_g = zeros(model.nGdof,1);
            for i = 1:size(model.point,1)
                % nodes only (not scalar points)
                if model.nodeFlag(i)
                    node = model.point(i);
                    a_g(node.gdof(1:3)) = node.T_g0*a_0;
                end
            end
            
            % calculate force from acceleration
            p_g = model.M_gg*a_g;
            gdof = 1:model.nGdof;
        end
    end
end
