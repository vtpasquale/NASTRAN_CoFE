% Class for output data at nodes
% Anthony Ricciardi
%
classdef node_output_data
    
    properties
        ID % [nnodes,1] Node ID number
        
        T1_0 % [nnodes,nsub] X translation in basic reference frame
        T2_0 % [nnodes,nsub] Y translation in basic reference frame
        T3_0 % [nnodes,nsub] Z translation in basic reference frame
        R1_0 % [nnodes,nsub] X rotation in basic reference frame
        R2_0 % [nnodes,nsub] Y rotation in basic reference frame
        R3_0 % [nnodes,nsub] Z rotation in basic reference frame
        
        TT % [nnodes,nsub] Total translation
        RT % [nnodes,nsub] Total rotation
        
        T1_g % [nnodes,nsub] X translation in nodal displacement reference frame
        T2_g % [nnodes,nsub] Y translation in nodal displacement reference frame
        T3_g % [nnodes,nsub] Z translation in nodal displacement reference frame
        R1_g % [nnodes,nsub] X rotation in nodal displacement reference frame
        R2_g % [nnodes,nsub] Y rotation in nodal displacement reference frame
        R3_g % [nnodes,nsub] Z rotation in nodal displacement reference frame
    end
    
    methods(Static = true)
        function node_output = from_u(ID,u_0,u_g)
            % Initialize node_output object based on displacement vectors
            node_output = node_output_data;
            
            node_output.ID=ID;
            node_output.T1_0=u_0(1:6:end,:);
            node_output.T2_0=u_0(2:6:end,:);
            node_output.T3_0=u_0(3:6:end,:);
            node_output.R1_0=u_0(4:6:end,:);
            node_output.R2_0=u_0(5:6:end,:);
            node_output.R3_0=u_0(6:6:end,:);
            
            node_output.TT = sqrt(node_output.T1_0.^2 + node_output.T2_0.^2 + node_output.T3_0.^2);
            node_output.RT = sqrt(node_output.T1_0.^2 + node_output.T2_0.^2 + node_output.T3_0.^2);
            
            node_output.T1_g=u_g(1:6:end,:);
            node_output.T2_g=u_g(2:6:end,:);
            node_output.T3_g=u_g(3:6:end,:);
            node_output.R1_g=u_g(4:6:end,:);
            node_output.R2_g=u_g(5:6:end,:);
            node_output.R3_g=u_g(6:6:end,:);
        end
    end
end
