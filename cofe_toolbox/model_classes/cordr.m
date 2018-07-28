% Class for rectangular coordinate systems
% Anthony Ricciardi
%
classdef cordr < cord

    properties
        CID % (Integer >= 0) Coordinate system identification number.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
    end
    
    %%
    methods
        function X_0 = X_0(obj,X_C) 
            % Returns location X ([3,1] Float) expressed in _0 from X expressed in _C
            X_0 = obj.TC_C0.'*X_C + obj.XC_0;
        end
        function X_C = X_C(obj,X_0)
            % Returns location X ([3,1] Float) expressed in _C from X expressed in _0
            X_C = obj.TC_C0*( X_0 - obj.XC_0);
        end
        function T_C0 = T_C0(obj,X_C) 
            % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at X_C
            T_C0 = obj.TC_C0;
        end
    end
end

