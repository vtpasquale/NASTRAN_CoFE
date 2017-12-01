% Abstract superclass for loads
% Anthony Ricciardi
%
classdef (Abstract) loads < matlab.mixin.Heterogeneous

    properties (Abstract)
        SID % [int] Load set identification number.
    end
    methods
    end
    
end

