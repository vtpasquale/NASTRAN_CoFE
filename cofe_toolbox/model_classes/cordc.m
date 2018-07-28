% Class for cylindrical coordinate systems
% Anthony Ricciardi
%
classdef cordc < cord
    
    properties
        CID % (Integer >= 0) Coordinate system identification number.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
    end
    
    %%
    methods
        function X_0 = X_0(obj,X_C) 
            % Returns location X ([3,1] Float) expressed in _0 from X expressed in _C
            XR_C = [X_C(1)*cosd(X_C(2));X_C(1)*sind(X_C(2));X_C(3)]; % rectangular location in C
            X_0 = obj.TC_C0.'*XR_C + obj.XC_0;
        end
        function X_C = X_C(obj,X_0)
            % Returns location X ([3,1] Float) expressed in _C from X expressed in _0
            XR_C = obj.TC_C0*( X_0 - obj.XC_0); % rectangular location in C
            X_C = [...
                sqrt(XR_C(1).^2+XR_C(2).^2); % R
                atan2d(XR_C(2),XR_C(1)); % Theta [this may introduce issues with complex step]
                XR_C(3)]; % Z
        end
        function T_C0 = T_C0(obj,X_C) 
            % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at X_C
            T_C0 = [cosd(X_C(2)), sind(X_C(2)), 0;
                   -sind(X_C(2)), cosd(X_C(2)), 0; 
                    0            , 0            , 1] ...
                   * obj.TC_C0;
        end
    end
end

