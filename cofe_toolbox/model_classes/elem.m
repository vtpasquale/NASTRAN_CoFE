% Abstract superclass for elastic elements
% Anthony Ricciardi
%
classdef (Abstract) elem < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        EID % [int] Element identification number.
        G % [1,: int] Node identification numbers of connection points.
    end
%     methods (Abstract)
%         obj = assemble(obj,MODEL) % Calculate element matricies
%     end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % preprocess elements
            
            % check that element id numbers are unique
            EIDS=[obj.EID];
            nelem = size(obj,1);
            [~,ia] = unique(EIDS,'stable');
            if size(ia,1)~=nelem
                nonunique=setxor(ia,1:nelem);
                error('Element identification numbers should be unique. Nonunique element identification number(s): %s',sprintf('%d,',EIDS(nonunique)))
            end
        end
        function MODELout = assemble_all(obj,MODEL)
            % assemble element and global matricies
            
            % Preallocate Sparse Matrices
            K = spalloc(MODEL.ngdof,MODEL.ngdof,20*MODEL.ngdof);
            M = K;
            
            % Loop through elements
            nelem = size(obj,1);
            for i=1:nelem
                obj_i=obj(i).assemble(MODEL);
                K(gdof,gdof)=K(gdof,gdof)+obj_i.kg;
                M(gdof,gdof)=M(gdof,gdof)+obj_i.mg;
            end
            MODELout.ELEM=objout;
            MODELout.K=K;
            MODELout.M=M;
        end
    end
end

