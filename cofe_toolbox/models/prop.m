% Abstract superclass for element properties
% Anthony Ricciardi
%
classdef (Abstract) prop < matlab.mixin.Heterogeneous

    properties (Abstract)
        PID % [int] Property identification number.
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % Function to preprocess properties
            
            % check that property id numbers are unique
            PIDS = [obj.PID];
            nprop = size(obj,1);
            [~,ia] = unique(PIDS,'stable');
            if size(ia,1)~=nprop
                nonunique=setxor(ia,1:nprop);
                error('Property identification numbers should be unique. Nonunique property identification number(s): %s',sprintf('%d,',PIDS(nonunique)))
            end
        end
    end
    
end

