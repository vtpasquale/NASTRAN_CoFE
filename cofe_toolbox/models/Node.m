% Class for model nodes
% Anthony Ricciardi
%
classdef Node < Point
    
    properties
        id  % [uint32] Node identification number.
        cp  % [uint32] Identification number of coordinate system in which the location of the node is defined.
        x_p % [3,1 double] Location of the node in coordinate system cp.
        cd % [uint32] Identification number of coordinate system in which the displacements, degrees-offreedom, constraints, and solution vectors are defined at the node.
        ps % [7, 1 logical] Permanent single-point constraints associated with nodal degrees of freedom. ps(1:6)==true where nodal degrees of freedom are perminantly constrained. ps(7)==true when the GRID ps field is not blank (default values used when GRID ps is blank - the seventh logical is needed because GRID ps=0 can be used to remove the default constraints defined on the GRDSET entry).
        
        x_0 % [3,1 double] Location of the node in the basic coordinate system.
        T_g0 % [3,3 double] Transoformation matrix from the basic coordinate system to node deformation coordinate system (defined in CD field)
        gdof % [1,6 uint32] index of global degrees of freedom associated with the node.
    end
    methods
        function obj = preprocess_sub(obj,model)
            % Function to preprocess nodes
            
            [nnodes,m]=size(obj);
            if m > 1; error('node.preprocess() can only handel nx1 arrays of node objects. The second dimension exceeds 1.'); end
            
            % Assign coordinate systems to default if unassigned
            for i = 1:nnodes
                if isempty(obj(i).cp); obj(i).cp=model.cpDefault; end
                if isempty(obj(i).cd); obj(i).cd=model.cdDefault; end
            end
            
            % set x_0 and T_g0 for all nodes
            coordinateSystem     = model.coordinateSystem;
            coordinateSystemCIDs = model.coordinateSystemCIDs;
            for i=1:nnodes
                oi = obj(i);
                oi.x_0  = coordinateSystem(oi.cp==coordinateSystemCIDs).x_0(oi.x_p);
                nodalDispCoordSys = coordinateSystem(oi.cd==coordinateSystemCIDs);
                oi.T_g0 = nodalDispCoordSys.T_c0(nodalDispCoordSys.x_c(oi.x_0));
                obj(i)=oi;
            end
        end
    end
end

