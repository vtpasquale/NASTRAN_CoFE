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
            K = spalloc(MODEL.ngdof,MODEL.ngdof,20*MODEL.ngdof);
            M = K;
            
            % Loop through elements
            nelem = size(obj,1);
            for i=1:nelem
                oi=obj(i).assemble(MODEL);
                K(oi.gdof,oi.gdof)=K(oi.gdof,oi.gdof)+oi.k_0;
                M(oi.gdof,oi.gdof)=M(oi.gdof,oi.gdof)+oi.m_0;
                obj(i)=oi;
            end
            MODEL.ELEM=obj;
            MODEL.K=K;
            MODEL.M=M;
        end
    end
end

