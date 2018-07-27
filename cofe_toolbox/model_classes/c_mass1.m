% Class for scalar mass elements.
% Anthony Ricciardi
%
classdef c_mass1 < elem
    
    properties
        EID % [int] Element identification number.
        PID % [int] Property identification number of a PROD entry. 
        G % [int] Node identification number.
        C % Component number. (0 < Integer < 6; blank or zero if scalar point)
        
        gdof
        m_e % [1 x 1] element mass matrix in the element reference frame
    end
    properties (Hidden=true)
        gdof_plot
    end
    properties (Constant=true)
        k_e = 0; % [1 x 1] element stiffness matrix in the element reference frame
        R_eg = 1;% [1 x 1] rotation matrix from the element reference frame to the nodal displacement reference frame
    end
    methods
        function obj=assemble(obj,MODEL)
            g1ind = obj.G==MODEL.nodeIDs;
            obj.gdof_plot = MODEL.node2gdof(:,g1ind);
            obj.gdof = obj.gdof_plot(obj.C);
            
            pty=MODEL.PROP(obj.PID==MODEL.propPIDs);
            if ~isa(pty,'p_mass');
                error('CMASS1 EID=%d references property PID = %d, which is not type PMASS. Only PMASS properties are supported for CMASS1 elements.',obj.EID,obj.PID);
            end
            obj.m_e = pty.M;
        end
    end
end
