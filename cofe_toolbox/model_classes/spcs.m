% Abstract superclass for single point constraints.
% Anthony Ricciardi
%
classdef (Abstract) spcs < matlab.mixin.Heterogeneous

    properties (Abstract)
        SID % [int] Identification number of the single-point constraint set.
    end
    methods
    end
    
end

