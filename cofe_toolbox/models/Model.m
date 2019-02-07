% Class that defines a finite element model.
% Anthony Ricciardi
classdef Model
        
    properties
        %% Model entities
        coordinateSystem@CoordinateSystem;
        material@Material;
        property@Property;
        point@Point; % Grid points (nodes) and scalar points
        element@Element;
        spcs@Spcs;
%         MPCS@mpcs;
        load@Load;
        
        %% Simple entities
        eigrl % [nEigrl,2 int] matrix with eigenvalue solver parameters [SID,ND], where SID = Set identification number and ND = number of roots desired.
        param % {nParam,3 cell array of [char]} [N,V1,V2] names and values of parameters
    end
    properties (Hidden=true)
        %% Sets translated from input data - processed after degrees-of-freedom are numbered
        dofSet@DofSet; % [nBulkEntry*set,1 DofSet]

        %% Exclusive Degrees-of-freedom sets
        m  % ([ngdof,1] logical) Degrees-of-freedom eliminated by multiple constraints
        sb % ([ngdof,numSID] logical) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
        sg % ([ngdof,1] logical) Degrees-of-freedom eliminated by single-point constraints that are specified on the PS field on node entries
        % o % ([ngdof,1] logical) Degrees-of-freedom omitted by structural matrix partitioning
        % q % ([ngdof,1] logical) Generalized degrees-of-freedom for dynamic reduction or component mode synthesis
        % r % ([ngdof,1] logical) Reference degrees-of-freedom used to determine free body motion
        % c % ([ngdof,1] logical) Degrees-of-freedom that are free during component mode synthesis or dynamic reduction
        % b % ([ngdof,1] logical) Degrees-of-freedom fixed during component mode analysis or dynamic reduction
        % e % ([ngdof,1] logical) extra degrees-of-freedom introduced in dynamic analysis
        % sa Permanently constrained aerodynamic degrees-of-freedom
        % k Aerodynamic degrees-of-freedom

        %% Nonexclusive Degrees-of-freedom sets
        s  % ([ngdof,numSID] logical) [sb + sg] Degrees-of-freedom eliminated by single point constraints
        % l % ([ngdof,1] logical) [b + c] Structural degrees-of-freedom remaining after the reference degrees-of-freedom are removed (degrees-of-freedom left over)
        % t % ([ngdof,1] logical) [l + r] Total set of physical boundary degrees-of-freedom for superelements
        % a % ([ngdof,1] logical) [t + q] Set assembled in superelement analysis
        % d % ([ngdof,1] logical) [a + e] Set used in dynamic analysis by the direct method
        f % ([ngdof,1] logical) [a + o] Unconstrained (free) structural degrees-of-freedom
        % fe % ([ngdof,1] logical) [f + e] Free structural degrees-of-freedom plus extra degrees-of-freedom
        n % ([ngdof,1] logical) [f + s] Degrees-of-freedom not constrained by multipoint constraints
        % ne % ([ngdof,1] logical) [n + e] Structural degrees-of-freedom not constrained by multipoint constraints plus extra degrees-of-freedom
        % g = true(ngdof,1) [n + m] All structural degrees-of-freedom including scalar degrees-of-freedom
        % p = [g + e] Physical degrees-of-freedom
        % ps = [p + sa] Physical and constrained (SPCi) aerodynamic degrees-of-freedom
        % pa = [ps + k] Physical set for aerodynamics
        % fr = [f ? q ? r] Statically independent set minus the statically determinate supports
        % v = [o + c + r] Set free to vibrate in dynamic reduction and component mode synthesis
        
        %% Set-related data
        sd % ([ngdof,numSID] sparse) Enforced displacement values due to single-point constraints that are included in boundary conditions
        
        %% Matricies
        K_g  % ([ngdof,ngdof] sparse) Elastic stiffness matrix in nodal displacement reference frame
        KD_g % ([ngdof,ngdof] sparse) Differential stiffness matrix in nodal displacement reference frame
        M_g  % ([ngdof,ngdof] sparse) Mass matrix in nodal displacement reference frame
        G
        p_g % ([ngdof,1] real) load vector in nodal displacement reference frame
        R_0g % ([ngdof,ngdof] sparse) Transformation matrix from nodal displacement reference frame to the basic reference frame
        

        %% Store vectors of ID numbers and other index data as seperate varables. 
        % This speeds up assembly because repeated concatenation is expensive.  
        coordinateSystemCIDs
        materialMIDs
        propertyPIDs
        elementEIDs
        spcsSIDs
        loadSIDs
        pointIDs
        
        nodeFlag % ([nPoints,1] logical) flags nodes in point array (not scalar points)
        nGdof % [uint32] number of global degrees of freedom

        %% Default Grid point properties:
        %  - Specified Grid points default to these options if not specified explicitly
        %  - Defaults can be chaged using GRDSET bulk data entry
        cpDefault=uint32(0); % [uint32] Default coordinate system in which the location of the grid points are defined.
        cdDefault=uint32(0); % [uint32] Default coordinate system in which the displacements, degrees-of-freedom, constraints, and solution vectors of the grid point are defined.
        psDefault=false(6,1); % [6,1 logical] Default dermanent single-point constraints on the grid point. ps(1:6)==true where nodal degrees of freedom are perminantly constrained.
    end
    methods
        function obj = preprocess(obj)
            
            % Preprocess model entities
            obj.coordinateSystem = obj.coordinateSystem.preprocess();   
            obj.coordinateSystemCIDs=[obj.coordinateSystem.cid]; 
            
            obj.material = obj.material.preprocess();
            obj.materialMIDs=[obj.material.mid].';
            
            obj.property = obj.property.preprocess(obj);
            obj.propertyPIDs = [obj.property.pid].';
            
            obj.elementEIDs=[obj.element.eid].';
            obj.loadSIDs=unique([obj.load.sid]).';
            
            obj = obj.point.preprocess(obj); % defines model.point, model.pointIDs, model.gNodeFlag, model.nGdof
            obj.element = obj.element.preprocess();
            obj.load = obj.load.preprocess(obj);
            
            % Process single-point constraints
            obj.sg = obj.point.getPerminantSinglePointConstraints(obj);
            [obj.sb,obj.sd,obj.spcsSIDs]=obj.spcs.process_sb(obj); % SID numbers and DOF eliminated by boundary single-point constraints
            
            % Define sets (in progress)
            obj.s = obj.sg | obj.sb;
            obj.f = ~obj.s;
        end
        function obj = assemble(obj)
                        
            % Assemble
            obj = obj.point.assemble(obj);
            obj = obj.element.assemble(obj); % element and global matricies
            obj = obj.load.assemble(obj);
            
        end
    end
end

