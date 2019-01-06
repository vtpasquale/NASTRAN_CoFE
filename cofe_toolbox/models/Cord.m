% Abstract superclass for coordinate systems
% Anthony Riccairdi
%
classdef (Abstract) Cord < matlab.mixin.Heterogeneous
    
    properties
        cid % (int32 >= 0) Coordinate system identification number.
        xc_0 % ([3,1] double) Coordinate system location in basic coordinate system.
    end
    properties (Access=protected)
        Tc_c0 % ([3,3] double) Transformation matrix from basic coordinate system to current coordinate system at current coordinate system origin
    end
    properties (Hidden=true)
        rid % (uint32 >= 0) Identification number of a coordinate system that is defined independently from this coordinate system.
        a % ([3,1] double) Coordinates of point a in coordinate system rid.
        b % ([3,1] double) Coordinates of point b in coordinate system rid.
        c % ([3,1] double) Coordinates of point c in coordinate system rid.
    end
    methods (Abstract)
        x_0 = x_0(obj,x_c) % Returns location x ([3,1] double) expressed in _0 from x expressed in _c
        x_c = x_c(obj,x_0) % Returns location x ([3,1] double) expressed in _c from x expressed in _0
        T_c0 = T_c0(obj,x_c) % Returns transformation matrix ([3,3] double) from basic coordinate system to current coordinate system at x_c
    end
    methods (Sealed = true)
        function obj = preprocess_all(obj)
            % function to preprocess coordinate systems
            [ncord,m]=size(obj);
            if m > 1; error('cord.preprocess() can only handel nx1 arrays of cord objects. The second dimension exceeds 1.'); end
            
            % check that id numbers are unique
            cids=[obj.cid];
            [~,ia] = unique(cids,'stable');
            if size(ia,1)~=ncord
                nonunique=setxor(ia,1:ncord);
                error('Coordinate systems identification numbers should be unique. Nonunique identification number(s): %s',sprintf('%d,',cids(nonunique)))
            end
            
            % Create basic coordinate system and add to array
            basicCsys = cordr; basicCsys.xc_0=zeros(3,1); basicCsys.Tc_c0=eye(3); % Basic Csys
            basicCsys.cid = 0; basicCsys.rid = -1;
            obj = [basicCsys;obj];
            cids=[0,cids];
            
            % preprocess coordinate systems accounting for dependency
            unresolved = cids; % unresolved coordinate systems
            iter = 1;
            while ~all(unresolved==0) % keep trying until dependencies resolved
                for i = 2:ncord+1
                    if unresolved(i) ~= 0
                        r = find(cids==obj(i).rid);
                        if isempty(r)==1
                            error('Coordinate systems CID = %d references an undefined coodinate system CID = %d',obj(i).cid,obj(i).rid)
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
        function obj = preprocess(obj,basicCsys)
            % Preprocess coordinate system
            
            % convert definition points to basic coordiate system
            a_0=basicCsys.x_0(obj.a);
            b_0=basicCsys.x_0(obj.b);
            c_0=basicCsys.x_0(obj.c);
            
            % Direction vectors
            dab = b_0-a_0;
            nu = (c_0-a_0);
            if all(abs(dab) < 1e5*eps) || all(abs(nu) < 1e5*eps)
                error(['Coordinate system CID = ',num2str(obj.cid),'is defined using coincident or close to coincident points.']);
            end
            
            % rotation matrix
            z = dab./norm_cs(dab);
            y = cross3(z,nu); y = y./norm_cs(y);
            x = cross3(y,z); x = x./norm_cs(x);
            
            obj.Tc_c0 = [x,y,z].';
            obj.xc_0 = a_0;
        end
    end
end

