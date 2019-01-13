% Class for scalar mass elements.
% Anthony Ricciardi
%
classdef Cmass1 < Element
    
    properties
        eid % [int] Element identification number.
        pid % [int] Property identification number of a PROD entry. 
        g % [int] Node identification number.
        c % Component number. (0 < Integer < 6)
        
        gdof
        m_e % [1 x 1] element mass matrix in the element reference frame
    end
    properties (Hidden=true)
        gdof_plot
        ELEMENT_TYPE = uint8(999); % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
    end
    properties (Constant=true)
        k_e = 0; % [1 x 1] element stiffness matrix in the element reference frame
        R_eg = 1;% [1 x 1] rotation matrix from the element reference frame to the nodal displacement reference frame
    end
    methods
        function obj=assemble_sub(obj,model)
            g1ind = obj.g==model.nodeIDs;
            obj.gdof_plot = model.node2gdof(:,g1ind);
            obj.gdof = obj.gdof_plot(obj.c);
            
            pty=model.property(obj.pid==model.propertyPIDs);
            if ~isa(pty,'Pmass');
                error('CMASS1 EID=%d references property PID = %d, which is not type PMASS. Only PMASS properties are supported for CMASS1 elements.',obj.eid,obj.pid);
            end
            obj.m_e = pty.m;
        end
        function [force,stress,strain,strain_energy] = recover_sub(obj,u_g,returnIO,opts)
            force=[];
            stress=[];
            strain=[];
            strain_energy=[];
        end
    end
end
