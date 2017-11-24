% Superclass for cylindrical coordinate systems
% Anthony Ricciardi
%
classdef cordc < cord
    
    properties (Abstract)
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
        TC_C0 % ([3,3] Symmetric Float) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    
    %%
    methods
        function XP_0 = XP_0(obj,XP_C) 
            % Returns location XP ([3,1] Float) expressed in _0 from XP expressed in _C
            XPR_C = [XP_C(1)*cosd(XP_C(2));XP_C(1)*sind(XP_C(2));XP_C(3)]; % rectangular location in C
            XP_0 = obj.TC_C0.'*XPR_C + obj.XC_0;
        end
        function XP_C = XP_C(obj,XP_0)
            % Returns location XP ([3,1] Float) expressed in _C from XP expressed in _0
            XPR_C = obj.TC_C0*( XP_0 - obj.XC_0); % rectangular location in C
            XP_C = [...
                sqrt(XPR_C(1).^2+XPR_C(2).^2); % R
                atan2d(XPR_C(2),XPR_C(1)); % Theta [this may introduce issues with complex step]
                XPR_C(3)]; % Z
        end
        function T_C0 = T_C0(obj,XP_C) 
            % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at XP_C
            T_C0 = [cosd(XP_C(2)), sind(XP_C(2)), 0;
                   -sind(XP_C(2)), cosd(XP_C(2)), 0; 
                    0            , 0            , 1] ...
                   * obj.TC_C0;
                
        end
    end
    
end

