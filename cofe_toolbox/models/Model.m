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
        %         mpc@Mpc;
        load@Load;
        
        superElement@SuperElement;
        
        %% Simple entities
        parameter@Parameter;
        eigrl % [nEigrl,2 int] matrix with eigenvalue solver parameters [SID,ND], where SID = Set identification number and ND = number of roots desired.
    end
    properties (Hidden=true)
        %% Sets translated from input data - processed after degrees-of-freedom are numbered
        dofSet@DofSet; % [nBulkEntry*set,1 DofSet]
        
        %% Exclusive Degrees-of-freedom sets
        m  % ([nGdof,1] logical) Degrees-of-freedom eliminated by multiple constraints
        sb % ([nGdof,numSID] logical) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
        sg % ([nGdof,1] logical) Degrees-of-freedom eliminated by single-point constraints that are specified on the PS field on node entries
        o % ([nGdof,1] logical) Degrees-of-freedom omitted by structural matrix partitioning
        q % ([nGdof,1] logical) Generalized degrees-of-freedom for dynamic reduction or component mode synthesis
        r % ([nGdof,1] logical) Reference degrees-of-freedom used to determine free body motion
        c % ([nGdof,1] logical) Degrees-of-freedom that are free during component mode synthesis or dynamic reduction
        b % ([nGdof,1] logical) Degrees-of-freedom fixed during component mode analysis or dynamic reduction
        % e % ([nGdof,1] logical) extra degrees-of-freedom introduced in dynamic analysis
        % sa Permanently constrained aerodynamic degrees-of-freedom
        % k Aerodynamic degrees-of-freedom
        
        %% Nonexclusive Degrees-of-freedom sets
        s  % ([nGdof,numSID] logical) [sb + sg] Degrees-of-freedom eliminated by single point constraints
        % l % ([nGdof,1] logical) [b + c] Structural degrees-of-freedom remaining after the reference degrees-of-freedom are removed (degrees-of-freedom left over)
        % t % ([nGdof,1] logical) [l + r] Total set of physical boundary degrees-of-freedom for superelements
        a % ([nGdof,1] logical) [t + q] Set assembled in superelement analysis
        % d % ([nGdof,1] logical) [a + e] Set used in dynamic analysis by the direct method
        f % ([nGdof,1] logical) [a + o] Unconstrained (free) structural degrees-of-freedom
        % fe % ([nGdof,1] logical) [f + e] Free structural degrees-of-freedom plus extra degrees-of-freedom
        n % ([nGdof,1] logical) [f + s] Degrees-of-freedom not constrained by multipoint constraints
        % ne % ([nGdof,1] logical) [n + e] Structural degrees-of-freedom not constrained by multipoint constraints plus extra degrees-of-freedom
        % g = true(nGdof,1) [n + m] All structural degrees-of-freedom including scalar degrees-of-freedom
        % p = [g + e] Physical degrees-of-freedom
        % ps = [p + sa] Physical and constrained (SPCi) aerodynamic degrees-of-freedom
        % pa = [ps + k] Physical set for aerodynamics
        % fr = [f ? q ? r] Statically independent set minus the statically determinate supports
        % v = [o + c + r] Set free to vibrate in dynamic reduction and component mode synthesis
        
        %% Set-related data
        sd % ([nGdof,numSID] sparse) Enforced displacement values due to single-point constraints that are included in boundary conditions
        
        %% Matricies
        K_gg  % ([nGdof,nGdof] sparse) Elastic stiffness matrix in nodal displacement reference frame
        KD_gg % ([nGdof,nGdof] sparse) Differential stiffness matrix in nodal displacement reference frame
        M_gg  % ([nGdof,nGdof] sparse) Mass matrix in nodal displacement reference frame
        G
        p_g % ([nGdof,1] real) load vector in nodal displacement reference frame
        R_0g % ([nGdof,nGdof] sparse) Transformation matrix from nodal displacement reference frame to the basic reference frame
        
        G_ot % ([nOdof,nTdof] double) Static boundary transformation matrix between the exterior and interior motion
        G_oq % ([nOdof,nQdof] double) Dynamic transformation matrix between the exterior and interior motion
        
        K_aa % ([nAdof,nAdof] double - possibly sparse) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] double - possibly sparse) Mass matrix of analysis set
        
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
        coupledMassFlag % [logical] Coupled mass formulation is used if true, lumped mass formulation used otherwise.
        reductionType % [uint8] Model reduction type: 0 = none, 1 = Guyan, 2 = dynamic
        
        %% Default Grid point properties:
        %  - Specified Grid points default to these options if not specified explicitly
        %  - Defaults can be chaged using GRDSET bulk data entry
        cpDefault=uint32(0); % [uint32] Default coordinate system in which the location of the grid points are defined.
        cdDefault=uint32(0); % [uint32] Default coordinate system in which the displacements, degrees-of-freedom, constraints, and solution vectors of the grid point are defined.
        psDefault=false(6,1); % [6,1 logical] Default dermanent single-point constraints on the grid point. ps(1:6)==true where nodal degrees of freedom are perminantly constrained.
    end
    methods
        function obj = preprocess(obj)
            [n,m]=size(obj);
            if m~=1; error('Function only operates on Model arrays size n x 1.'); end
            for i = 1:n
                obj(i) = preprocess_sub(obj(i));
            end
        end
        function obj = assemble(obj)
            [n,m]=size(obj);
            if m~=1; error('Function only operates on Model arrays size n x 1.'); end
            for i = 1:n
                obj(i) = assemble_sub(obj(i));
            end
        end
    end
    methods (Access = private)
        function obj = preprocess_sub(obj)
            
            % Preprocess model entities
            obj = obj.parameter.preprocess(obj);
            
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
            
            % Process single-point constraint sets
            obj.sg = obj.point.getPerminantSinglePointConstraints(obj);
            [obj.sb,obj.sd,obj.spcsSIDs]=obj.spcs.process_sb(obj); % SID numbers and DOF eliminated by boundary single-point constraints
            obj.s = obj.sg | obj.sb;
            
            % Process multi-point constraint sets? - or wait for assembly?
            
            % Process sets
            obj = obj.dofSet.preprocess(obj);
            obj.f = ~obj.s;
            
            
        end
        function obj = assemble_sub(obj)
            % Assemble
            obj = obj.point.assemble(obj);
            obj = obj.element.assemble(obj); % element and global matricies
            obj = obj.load.assemble(obj);
            obj = DofSet.assemble(obj); % model reduction sets
            
            obj = obj.modelReduction();
        end
        function obj = modelReduction(obj)
            if all(obj.a==obj.f) 
                % no model reduction
                obj.reductionType = uint8(0);
                obj.K_aa = obj.K_gg(obj.f,obj.f);
                obj.M_aa = obj.M_gg(obj.f,obj.f);
            elseif ~any(obj.q)
                % Guyan reduction
                obj.reductionType = uint8(1);
                obj = obj.guyanReduction();
            else
                % dynamic reduction
                error('Implement')
            end
            
        end
        function u_g = modelExpansion(obj,u_a)
            
            % preallocate
            nVectors = size(u_a,2);
            u_g=zeros(obj.nGdof,nVectors);
            
            % prescribed DOF
%             u_g(obj.s,:) = repmat(obj.sd,[1,nVectors]);
            
            % solved DOF
            switch obj.reductionType
                case 0
                    % no model expansion
                    u_g(obj.f,:) = u_a;
                case 1
                    % Guyan expansion
                    u_g(obj.a,:) = u_a;
                    u_g(obj.o,:) = obj.G_ot*u_a; % additional term if load applied at o-set
                case 2
                    % Dynamic expansion
                    u_g(obj.a,:) = u_a;
                    u_g(obj.o,:) = obj.G_ot*u_t + obj.G_oq*u_q; % additional term if load applied at o-set
                    
                otherwise
                    error('')
            end
            
            
        end
        function obj = guyanReduction(obj)
            % Implement Guyan reduction (a.k.a. static condensation)
            % Exact Stiffness Matrix Reduction
            % For Guyan reduction only, the a set is also the t set
            K_oo = obj.K_gg(obj.o,obj.o);
            K_ot = obj.K_gg(obj.o,obj.a);
            obj.G_ot = - K_oo\K_ot;
            obj.K_aa = obj.K_gg(obj.a,obj.a) +  K_ot.'* obj.G_ot;
            % Approximate Mass Matrix Reduction
            M_oo = obj.M_gg(obj.o,obj.o);
            M_ot = obj.M_gg(obj.o,obj.a);
            obj.M_aa = obj.M_gg(obj.a,obj.a) +  M_ot.'*obj.G_ot + ...
                obj.G_ot.'*M_ot + obj.G_ot.'*M_oo*obj.G_ot;
        end
        function obj = dynamicReduction(obj)
            % Implement dynamic reduction 
            % Start with HCB only
            K_oo = obj.K_gg(obj.o,obj.o);
            K_ot = obj.K_gg(obj.o,obj.a);
            obj.G_ot = - K_oo\K_ot;
            M_oo = obj.M_gg(obj.o,obj.o);
            [V,D] = eigs(M_oo,K_oo,nModes); % -> (1/w^2) * K * V = M * V is more reliable than K * V = w^2 * M * V
            eigenvalues = diag(D).^-1;
            for mn = 1:nModes
                if sum(V(:,mn)) < 0
                    V(:,mn) = -V(:,mn);
                end
                V(:,mn) = V(:,mn)./sqrt(V(:,mn).'*M_oo*V(:,mn));
            end
            obj.G_oq = V;
            nBset = size(obj.G_ot,2);
            nOset = size(obj.G_ot,1);
            %
            % Update for qset indexing...
            %
            T = [obj.G_ot,obj.G_oq;eye(nBset),zeros(nOset)];
            obj.K_aa = T.'*obj.K_gg(obj.f,obj.f)*T;
            obj.M_aa = T.'*obj.K_gg(obj.f,obj.f)*T;
        end
    end
end
