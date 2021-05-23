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
        % gdof_plot
        ELEMENT_TYPE = uint8(999); % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
    end
    properties % (Constant=true)
        k_e = 0; % [1 x 1] element stiffness matrix in the element reference frame
        R_eg = 1;% [1 x 1] rotation matrix from the element reference frame to the nodal displacement reference frame
        volume  = 0;% [double] element volume
        mass = 0;% [double] element mass
    end
    methods
        function obj=assemble_sub(obj,model)           
            node = model.point.getNode(obj.g,model);
            % obj.gdof_plot = node.gdof;
            obj.gdof = node.gdof(obj.c);
            
            pty = model.property.getProperty(obj.pid,model,'Pmass');
            obj.m_e = pty.m;
            
            
        end
        function [force,stress,strain,strainEnergy,kineticEnergy] = recover_sub(obj,u_g,model,returnFlags)
            force=[];
            stress=[];
            strain=[];
            strainEnergy=[];
            kineticEnergy=[];
        end
    end
end
