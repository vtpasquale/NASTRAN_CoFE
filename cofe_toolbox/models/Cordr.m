% Class for rectangular coordinate systems
% Anthony Ricciardi
%
classdef Cordr < Cord

    methods
        function x_0 = x_0(obj,x_c) 
            % Returns location x ([3,1] double) expressed in _0 from x expressed in _c
            x_0 = obj.Tc_c0.'*x_c + obj.xc_0;
        end
        function x_c = x_c(obj,x_0)
            % Returns location x ([3,1] double) expressed in _c from x expressed in _0
            x_c = obj.Tc_c0*( x_0 - obj.xc_0);
        end
        function T_c0 = T_c0(obj,x_c) 
            % Returns transformation matrix ([3,3] double) from basic coordinate system to current coordinate system at x_c
            T_c0 = obj.Tc_c0;
        end
    end
end

