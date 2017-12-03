% Class for point force vectors.
% Anthony Ricciardi
%
classdef forces < loads
    
    properties
        SID % [int] Load set identification number.
        G % [int] Grid point identification number.
        CID % [int] Coordinate system identification number.
        F % [3,1 real] Force vector expressed in coordinate system defined by CID.
        
        gdof
        p
    end
    methods
        function obj=assemble(obj,MODEL)
            gind = obj.G==MODEL.nodeIDs;
            obj.gdof = MODEL.node2gdof(1:3,gind);
            
            obj.p = obj.F; % update for coordinate systems
        end
    end
end
