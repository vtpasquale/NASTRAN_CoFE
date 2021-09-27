% Class for enforced displacements.
% Anthony Ricciardi
%
classdef Spcd < Load
    
    properties
        sid % [uint32] Load set identification number.
        c % [nComponents,1 uint32] Component numbers between 0 and 6.
        g % [uint32] Point identification number.
        d % [double] Value of enforced displacement for components c.
    end
    methods
        function [ue_s,gdof]=assemble_sub(obj,model)
            % Outputs
            % gdof [1,nComponents uint32] index of global degrees of freedom
            % u_s [nComponents,1 double] Force vector expressed in the nodal displacement coordinate system defined at grid points.
            point = model.point.getPoint(obj.g,model);
            if isa(point,'Node')
                gdof = point.gdof(obj.c);
            elseif isa(point,'ScalarPoint')
                if oj.c~=0
                    error('Only component zero can be fixed for a scalar point.')
                end
                gdof = point.gdof;
            else
                error('Update Spcd class for new point type.')
            end
            ue_s = obj.d;
        end
    end
end
