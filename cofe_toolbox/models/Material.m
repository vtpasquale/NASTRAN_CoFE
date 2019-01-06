% Abstract superclass for materials.
% Anthony Ricciardi
%
classdef (Abstract) Material < matlab.mixin.Heterogeneous

    properties (Abstract)
        mid % [uint32] Material identification number.
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % Function to preprocess properties
            
            % check that property id numbers are unique
            MIDS=[obj.MID];
            nprop = size(obj,1);
            [~,ia] = unique(MIDS,'stable');
            if size(ia,1)~=nprop
                nonunique=setxor(ia,1:nprop);
                error('Material identification numbers should be unique. Nonunique material identification number(s): %s',sprintf('%d,',MIDS(nonunique)))
            end
        end
    end
end

