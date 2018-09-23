% Class for spherical coordinate systems
% Anthony Ricciardi
%
classdef cords < cord

    methods
        function x_0 = x_0(obj,x_c) 
            % Returns location x ([3,1] double) expressed in _0 from x expressed in _c
            xr_c =([cosd(x_c(2)), 0, -sind(x_c(2)); % R2
                    0            , 1,  0
                    sind(x_c(2)), 0,  cosd(x_c(2))]...
                  *[cosd(x_c(3)), sind(x_c(3)), 0; % R3
                   -sind(x_c(3)), cosd(x_c(3)), 0; 
                    0            , 0            , 1]).'...
                  *[0;0;x_c(1)];
            x_0 = obj.Tc_c0.'*xr_c + obj.xc_0;
        end
        function x_c = x_c(obj,x_0)
            % Returns location x ([3,1] double) expressed in _c from x expressed in _0
            xr_c = obj.Tc_c0*( x_0 - obj.xc_0); % rectangular location in C
            %
            Phi = atan2d(xr_c(2),xr_c(1)); % Phi [this may introduce issues with complex step]
            xr_cR3 = [cosd(Phi), sind(Phi), 0; % R3
                      -sind(Phi), cosd(Phi), 0; 
                       0        , 0        , 1]...
                      *xr_c; % rectangular location in CR3 - after Phi rotation
            %
            Theta = atan2d(xr_cR3(1),xr_cR3(3)); % Theta [this may introduce issues with complex step]
            %
            x_c = [sqrt(xr_c(1).^2+xr_c(2).^2+xr_c(3).^2); % R
                    Theta; % Theta
                    Phi]; % Phi [this may introduce issues with complex step]
        end
        function T_c0 = T_c0(obj,x_c) 
            % Returns transformation matrix ([3,3] double) from basic coordinate system to current coordinate system at x_c
            R2 = [cosd(x_c(2)), 0           ,-sind(x_c(2)) 
                  0           , 1           ,  0
                  sind(x_c(2)), 0           ,  cosd(x_c(2))];
            R3 = [cosd(x_c(3)), sind(x_c(3)), 0;
                 -sind(x_c(3)), cosd(x_c(3)), 0; 
                  0           , 0           , 1] ;
            T_c0 = [0 0 1;1 0 0;0 1 0]*R2*R3*obj.Tc_c0;
        end
    end
end

