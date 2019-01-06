% Abstract superclass for element properties
% Anthony Ricciardi
%
classdef (Abstract) Property < matlab.mixin.Heterogeneous

    properties (Abstract)
        pid % [int] Property identification number.
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % Function to preprocess properties
            
            % check that property id numbers are unique
            pids = [obj.pid];
            nprop = size(obj,1);
            [~,ia] = unique(pids,'stable');
            if size(ia,1)~=nprop
                nonunique=setxor(ia,1:nprop);
                error('Property identification numbers should be unique. Nonunique property identification number(s): %s',sprintf('%d,',pids(nonunique)))
            end
        end
    end
    
end

