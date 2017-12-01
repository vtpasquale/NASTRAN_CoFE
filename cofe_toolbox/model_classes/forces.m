% Class for point force vectors.
% Anthony Ricciardi
%
classdef forces < loads
    
    properties
        SID % [int] Load set identification number.
        G % [int] Grid point identification number.
        CID % [int] Coordinate system identification number.
        F % [3,1 real] Force vector expressed in coordinate system defined by CID.
    end
    methods
    end
end
