% Abstract superclass for elastic elements
% Anthony Ricciardi
%
classdef (Abstract) elem < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        EID % [int] Element identification number.
        G % [1,: int] Node identification numbers of connection points.
    end
    methods (Abstract)
        obj = assemble(obj,MODEL) % Calculate element matricies
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % preprocess elements
            [nelem,m] = size(obj);
            if m > 1; error('elem.preprocess() can only handel nx1 arrays of elem objects. The second dimension exceeds 1.'); end
            
            % check that element id numbers are unique
            EIDS=[obj.EID];
            
            [~,ia] = unique(EIDS,'stable');
            if size(ia,1)~=nelem
                nonunique=setxor(ia,1:nelem);
                error('Element identification numbers should be unique. Nonunique element identification number(s): %s',sprintf('%d,',EIDS(nonunique)))
            end
        end
        function MODEL = assemble_all(obj,MODEL)
            % assemble element and global matricies
            
            % Preallocate Sparse Matrices
            K_g = spalloc(MODEL.ngdof,MODEL.ngdof,20*MODEL.ngdof);
            M_g = K_g;
            
            % Loop through elements
            nelem = size(obj,1);
            for i=1:nelem
                oi=obj(i).assemble(MODEL);
                K_g(oi.gdof,oi.gdof)=K_g(oi.gdof,oi.gdof)+oi.R_eg.'*oi.k_e*oi.R_eg;
                M_g(oi.gdof,oi.gdof)=M_g(oi.gdof,oi.gdof)+oi.R_eg.'*oi.m_e*oi.R_eg;
                obj(i)=oi;
            end
            MODEL.ELEM=obj;
            MODEL.K_g=K_g;
            MODEL.M_g=M_g;
        end
    end
end

