% Abstract superclass for loads
% Anthony Ricciardi
%
classdef (Abstract) loads < matlab.mixin.Heterogeneous

    properties (Abstract)
        SID % [int] Load set identification number.
    end
    methods
        function MODEL = process(obj,MODEL)
            nloads = size(obj,1);
            ncases = size(MODEL.loadsSIDs,1);
            p = zeros(MODEL.ngdof,ncases);
            
            % Loop through loads
            for i=1:nloads
                oi=obj(i).assemble(MODEL);
                lc = find(oi.SID==MODEL.loadsSIDs);
                p(oi.gdof,lc)=p(oi.gdof,lc)+oi.p;
                obj(i)=oi;
            end
            MODEL.LOADS=obj;
            MODEL.p=p;
        end
    end
    
end

