% Class for model scalar points
% Anthony Ricciardi
%
classdef ScalarPoint < Point
    
    properties
        id  % [uint32] Point identification number.
        gdof % [uint32] index of global degree of freedom associated with the scalar point.
    end
end

