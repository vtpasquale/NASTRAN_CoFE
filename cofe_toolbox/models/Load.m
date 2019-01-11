% Abstract superclass for loads
% Anthony Ricciardi
%
classdef (Abstract) Load < matlab.mixin.Heterogeneous

    properties (Abstract)
        sid % [int] Load set identification number.
    end
    methods (Sealed=true)
        function obj = preprocess(obj,MODEL)
            % preprocess loads
            [nloads,m] = size(obj);
            if m > 1; error('loads.preprocess() can only handel nx1 arrays of loads objects. The second dimension exceeds 1.'); end
            
            % Loop through loads
            for i=1:nloads
                obj(i)=obj(i).preprocess_sub(MODEL);
            end
        end
        function model = assemble(obj,model)
            nLoads = size(obj,1);
            nCases = size(model.loadSIDs,1);
            p_g = zeros(model.ngdof,nCases);
            
            % Loop through loads
            for i=1:nLoads
                oi=obj(i);
                lc = find(oi.sid==model.loadSIDs);
                p_g(oi.gdof,lc)=p_g(oi.gdof,lc)+oi.p_g;
            end
            model.p_g=p_g;
        end
    end
    
end

