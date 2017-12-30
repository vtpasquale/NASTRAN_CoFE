% Abstract superclass for coordinate systems
% Anthony Riccairdi
%
classdef (Abstract) cord < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        CID % (Integer >= 0) Coordinate system identification number.
        XC_0 % ([3,1] Float) Csys location in basic coordinate system.
        TC_C0 % ([3,3] Symmetric Float) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    properties (Hidden=true)
        RID % (Integer >= 0) Identification number of a coordinate system that is defined independently from this coordinate system.
        A % ([3,1] Float) Coordinates of point A in coordinate system RID.
        B % ([3,1] Float) Coordinates of point B in coordinate system RID.
        C % ([3,1] Float) Coordinates of point C in coordinate system RID.
    end
    methods (Abstract)
        X_0 = X_0(obj,X_C) % Returns location X ([3,1] Float) expressed in _0 from X expressed in _C
        X_C = X_C(obj,X_0) % Returns location X ([3,1] Float) expressed in _C from X expressed in _0
        T_C0 = T_C0(obj,X_C) % Returns transformation matrix ([3,3] Symmetric Float) from basic coordinate system to current coordinate system at X_C
    end
    methods (Sealed = true)
        function obj = preprocess_all(obj)
            % function to preprocess coordinate systems
            [ncord,m]=size(obj);
            if m > 1; error('cord.preprocess() can only handel nx1 arrays of cord objects. The second dimension exceeds 1.'); end
            
            % check that element id numbers are unique
            CIDS=[obj.CID];
            [~,ia] = unique(CIDS,'stable');
            if size(ia,1)~=ncord
                nonunique=setxor(ia,1:ncord);
                error('Element identification numbers should be unique. Nonunique element identification number(s): %s',sprintf('%d,',CIDS(nonunique)))
            end
            
            % Create basic coordinate system and add to array
            Robj = cordr; Robj.XC_0=zeros(3,1); Robj.TC_C0=eye(3); % Basic Csys
            Robj.CID = 0; Robj.RID = -1;
            obj = [Robj;obj];
            CIDS=[0,CIDS];
            
            % preprocess coordinate systems accounting for dependency
            unresolved = CIDS; % unresolved coordinate systems
            iter = 1;
            while ~all(unresolved==0) % keep trying until dependencies resolved
                for i = 2:ncord+1
                    if unresolved(i) ~= 0
                        r = find(CIDS==obj(i).RID);
                        if isempty(r)==1
                            error('Coordinate systems CID = %d references an undefined coodinate system CID = %d',obj(i).CID,obj(i).RID)
                        else
                            if unresolved(r) == 0
                                obj(i)=obj(i).preprocess(obj(r));
                                unresolved(i) = 0;
                            end
                        end
                    end
                end
                iter = iter + 1;
                if iter > ncord+2
                    error('There are dependency issues with coordinate system(s) CID = %s',sprintf('%d, ',unresolved(unresolved~=0)'))
                end
            end
        end
    end
    methods
        function obj = preprocess(obj,Robj)
            % Preprocess coordinate system
            
            % convert definition points to basic coordiate system
            A_0=Robj.X_0(obj.A);
            B_0=Robj.X_0(obj.B);
            C_0=Robj.X_0(obj.C);
            
            % Direction vectors
            dAB = B_0-A_0;
            nu = (C_0-A_0);
            if all(abs(dAB) < 1e5*eps) || all(abs(nu) < 1e5*eps)
                error(['Coordinate system CID = ',num2str(obj.CID),'is defined using coincident or close to coincident points.']);
            end
            
            % rotation matrix
            z = dAB./norm_cs(dAB);
            y = cross3(z,nu); y = y./norm_cs(y);
            x = cross3(y,z); x = x./norm_cs(x);
            
            obj.TC_C0 = [x,y,z].';
            obj.XC_0 = A_0;
        end
    end
end

