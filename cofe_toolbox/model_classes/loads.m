% Abstract superclass for loads
% Anthony Ricciardi
%
classdef (Abstract) loads < matlab.mixin.Heterogeneous

    properties (Abstract)
        SID % [int] Load set identification number.
    end
    methods
        function MODEL = process(obj,MODEL)
            p = zeros(MODEL.ngdof,1);
            % Loop through loads
            nloads = size(obj,1);
            for i=1:nloads
                oi=obj(i).assemble(MODEL);
                p(oi.gdof)=p(oi.gdof)+oi.p;
                obj(i)=oi;
            end
            MODEL.LOADS=obj;
            MODEL.p=p;
        end
    end
    
end

