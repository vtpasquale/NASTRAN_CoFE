% Class that defines a finite element model.
% Anthony Ricciardi
classdef Model
        
    properties
        %% Model entities
        coordinateSystem@CoordinateSystem;
        material@Material;
        property@Property;
        node@Node;
        element@Element;
        spcs@Spcs;
%         MPCS@mpcs;
        load@Load;
        
        %% Simple entities
        eigTab=[]; % [:,2 int] table with eigenvalue solver parameters [SID,ND], where SID = Set identification number and ND = number of roots desired.
        
        %% Sets and related
        sb % ([ngdof,num SID] logical) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
        sd % ([ngdof,num SID] sparse) Enforced displacement values due to single-point constraints that are included in boundary conditions
        sg % ([ngdof,1] logical) Degrees-of-freedom eliminated by single-point constraints that are specified on the PS field on node entries.
        s  % ([ngdof,1] logical) All degrees-of-freedom eliminated by single point constraints -> sb + sg
        f  % ([ngdof,1] logical) Unconstrained (free) structural degrees-of-freedom -> a + o 
        m  % ([ngdof,1] logical) All degrees-of-freedom eliminated by multiple constraints
        n  % ([ngdof,1] logical) All degrees-of-freedom not constrained by multipoint constraints
        
        %% Matricies
        K_g  % ([ngdof,ngdof] sparse) Elastic stiffness matrix in nodal displacement reference frame
        KD_g % ([ngdof,ngdof] sparse) Differential stiffness matrix in nodal displacement reference frame
        M_g  % ([ngdof,ngdof] sparse) Mass matrix in nodal displacement reference frame
        G
        p_g % ([ngdof,1] real) load vector in nodal displacement reference frame
        R_0g % ([ngdof,ngdof] sparse) Transformation matrix from nodal displacement reference frame to the basic reference frame
        
    end
    properties (Hidden=true)
        coordinateSystemCIDs
        materialMIDs
        propertyPIDs
        nodeIDs
        elementEIDs
        spcsSIDs
        loadSIDs
        
        node2gdof
        ngdof
    end

    methods
        function obj = preprocess(obj)
            nnodes = size(obj.node,1);
            obj.ngdof       = 6*nnodes;
            obj.node2gdof   = zeros(6,nnodes);
            obj.node2gdof(:)= 1:obj.ngdof;
            
            % Preprocess coordinate systems
            obj.coordinateSystem = obj.coordinateSystem.preprocess();
            
            % Store vectors of ID numbers as seperate varables. This speeds 
            % up assembly because repeated concatenation is expensive.        
            obj.coordinateSystemCIDs=[obj.coordinateSystem.cid]; 
            obj.materialMIDs=[obj.material.mid].';
            obj.propertyPIDs=[obj.property.pid].';
            obj.nodeIDs=[obj.node.id].';
            obj.elementEIDs=[obj.element.eid].';
            obj.loadSIDs=unique([obj.load.sid]).';
            
            % Preprocess remaining model entities
            obj.material = obj.material.preprocess();
            obj.property = obj.property.preprocess();
            obj.node = obj.node.preprocess(obj);
            obj.element = obj.element.preprocess();
            obj.load = obj.load.preprocess(obj);
            
            % Process single-point constraints
            obj.sg = obj.node.getPerminantSinglePointConstraints();
            [obj.sb,obj.sd,obj.spcsSIDs]=obj.spcs.process_sb(obj.node2gdof,obj.nodeIDs); % SID numbers and DOF eliminated by boundary single-point constraints
            
            % Define sets (in progress)
            obj.s = obj.sg | obj.sb;
            obj.f = ~obj.s;
        end
        function obj = assemble(obj)
            
            % Process MAT references in prop entries to speed things up?
            
            % Assemble
            obj = obj.node.assemble(obj);
            obj = obj.element.assemble(obj); % element and global matricies
            obj = obj.load.assemble(obj);
            
        end
    end
    
end

