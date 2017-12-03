% Class for rectangular coordinate systems
% Anthony Ricciardi
%
classdef cordr < cord

    properties
        CID % (Integer >= 0) Coordinate system identification number.
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
    methods
        function obj = preprocess(obj,Robj)
            % Preprocess coordinate system
            
            % convert definition points to basic coordiate system
            A_0=Robj.XP_0(obj.A);
            B_0=Robj.XP_0(obj.B);
            C_0=Robj.XP_0(obj.C);
            
            % Direction vectors
            dAB = B_0-A_0;
            nu = (C_0-A_0);
            if all(abs(dAB) < 1e5*eps) || all(abs(nu) < 1e5*eps)
                error(['Coordinate system CID = ',num2str(obj.CID),'is defined using coincident or close to coincident points.']);
            end
            
            % rotation matrix
            z = dAB./norm_cs(dAB);
            y = cross3(z,nu); y = y./norm(y);
            x = cross3(y,z); x = x./norm(x);
            % T_CR = [x,y,z];
            
            obj.TC_C0 = [x,y,z]; % T_CR*Robj.TC_C0;
            obj.XC_0 = Robj.XC_0 + A_0;
        end
    end
end

