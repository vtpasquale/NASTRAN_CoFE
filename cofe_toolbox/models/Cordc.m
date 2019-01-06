% Class for cylindrical coordinate systems
% Anthony Ricciardi
%
classdef Cordc < Cord
    
    methods
        function x_0 = x_0(obj,x_c) 
            % Returns location x ([3,1] double) expressed in _0 from x expressed in _c
            xr_c = [x_c(1)*cosd(x_c(2));x_c(1)*sind(x_c(2));x_c(3)]; % rectangular location in C
            x_0 = obj.Tc_c0.'*xr_c + obj.xc_0;
        end
        function x_c = x_c(obj,x_0)
            % Returns location x ([3,1] double) expressed in _c from x expressed in _0
            xr_c = obj.Tc_c0*( x_0 - obj.xc_0); % rectangular location in C
            x_c = [...
                sqrt(xr_c(1).^2+xr_c(2).^2); % R
                atan2d(xr_c(2),xr_c(1)); % Theta [this may introduce issues with complex step]
                xr_c(3)]; % Z
        end
        function T_c0 = T_c0(obj,x_c) 
            % Returns transformation matrix ([3,3] double) from basic coordinate system to current coordinate system at x_c
            T_c0 = [cosd(x_c(2)), sind(x_c(2)), 0;
                   -sind(x_c(2)), cosd(x_c(2)), 0; 
                    0            , 0            , 1] ...
                   * obj.Tc_c0;
        end
    end
end

