% Superclass for rectangular coordinate systems
% Anthony Ricciardi
%
classdef cordr < cord

    properties (Abstract)
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
        TC_C0 % ([3,3] Symmetric Float) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    
    %%
    methods
        function XP_0 = XP_0(obj,XP_C) 
            % Returns location XP ([3,1] Float) expressed in _0 from XP expressed in _C
            XP_0 = obj.TC_C0.'*XP_C + obj.XC_0;
        end
        function XP_C = XP_C(obj,XP_0)
            % Returns location XP ([3,1] Float) expressed in _C from XP expressed in _0
            XP_C = obj.TC_C0*( XP_0 - obj.XC_0);
        end
        function T_C0 = T_C0(obj,XP_C) 
            % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at XP_C
            T_C0 = obj.TC_C0;
        end
    end
    
end

