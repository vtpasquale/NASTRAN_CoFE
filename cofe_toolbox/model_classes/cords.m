% Class for spherical coordinate systems
% Anthony Ricciardi
%
classdef cords < cord
    
    properties
        CID % (Integer >= 0) Coordinate system identification number.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
    end
    
    %%
    methods
        function X_0 = X_0(obj,X_C) 
            % Returns location X ([3,1] Float) expressed in _0 from X expressed in _C
            XR_C =([cosd(X_C(2)), 0, -sind(X_C(2)); % R2
                    0            , 1,  0
                    sind(X_C(2)), 0,  cosd(X_C(2))]...
                  *[cosd(X_C(3)), sind(X_C(3)), 0; % R3
                   -sind(X_C(3)), cosd(X_C(3)), 0; 
                    0            , 0            , 1]).'...
                  *[0;0;X_C(1)];
            X_0 = obj.TC_C0.'*XR_C + obj.XC_0;
        end
        function X_C = X_C(obj,X_0)
            % Returns location X ([3,1] Float) expressed in _C from X expressed in _0
            XR_C = obj.TC_C0*( X_0 - obj.XC_0); % rectangular location in C
            %
            Phi = atan2d(XR_C(2),XR_C(1)); % Phi [this may introduce issues with complex step]
            XR_CR3 = [cosd(Phi), sind(Phi), 0; % R3
                      -sind(Phi), cosd(Phi), 0; 
                       0        , 0        , 1]...
                      *XR_C; % rectangular location in CR3 - after Phi rotation
            %
            Theta = atan2d(XR_CR3(1),XR_CR3(3)); % Theta [this may introduce issues with complex step]
            %
            X_C = [sqrt(XR_C(1).^2+XR_C(2).^2+XR_C(3).^2); % R
                    Theta; % Theta
                    Phi]; % Phi [this may introduce issues with complex step]
        end
        function T_C0 = T_C0(obj,X_C) 
            % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at X_C
            R2 = [cosd(X_C(2)), 0           ,-sind(X_C(2)) 
                  0           , 1           ,  0
                  sind(X_C(2)), 0           ,  cosd(X_C(2))];
            R3 = [cosd(X_C(3)), sind(X_C(3)), 0;
                 -sind(X_C(3)), cosd(X_C(3)), 0; 
                  0           , 0           , 1] ;
            T_C0 = [0 0 1;1 0 0;0 1 0]*R2*R3*obj.TC_C0;
        end
    end
end

