% Class that defines a finite element model.
% Anthony Ricciardi
classdef Model
    
    properties
        %% Superelement
        superElementID; % [uint32]
        
        %% Case control
        caseControl@CaseControl;
        
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
        reducedModel
        
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
        t % ([nGdof,1] logical) [l + r] Total set of physical boundary degrees-of-freedom for superelements
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
        
        % seconct % ([nGdof,1] logical) Degrees-of-freedom connected to other superelements, as specified on seconct entrires
        
        %% Set-related data
        sd % ([nGdof,numSID] sparse) Enforced displacement values due to single-point constraints that are included in boundary conditions
        superElementConnections % ([nGdof,nSuperElements] sparse) Superelement connections, exists only in residual structure model
        
        aSetIndexInGSet  % [nAsetDof,1 uint32] GSET index (in this superelement) of boundary DOF defined by SECONCT
        aSetIndexInGSet0 % [nAsetDof,1 uint32] GSET index (in residual structure) of boundary DOF defined by SECONCT
        aSetIndexInASet0 % [nAsetDof,1 uint32] ASET index (in residual structure) of boundary DOF defined by SECONCT
        
        
        %% Matricies
        K_gg  % ([nGdof,nGdof] sparse) Elastic stiffness matrix in nodal displacement reference frame
        KD_gg % ([nGdof,nGdof] sparse) Differential stiffness matrix in nodal displacement reference frame
        M_gg  % ([nGdof,nGdof] sparse) Mass matrix in nodal displacement reference frame
        G
        p_g % ([nGdof,1] real) load vector in nodal displacement reference frame
        R_0g % ([nGdof,nGdof] sparse) Transformation matrix from nodal displacement reference frame to the basic reference frame
        
        % G_ot % ([nOdof,nTdof] double) Static boundary transformation matrix between the exterior and interior motion
        % G_oq % ([nOdof,nQdof] double) Dynamic transformation matrix between the exterior and interior motion
        
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
        
        %% Default Grid point properties:
        %  - Specified Grid points default to these options if not specified explicitly
        %  - Defaults can be chaged using GRDSET bulk data entry
        cpDefault=uint32(0); % [uint32] Default coordinate system in which the location of the grid points are defined.
        cdDefault=uint32(0); % [uint32] Default coordinate system in which the displacements, degrees-of-freedom, constraints, and solution vectors of the grid point are defined.
        psDefault=false(6,1); % [6,1 logical] Default dermanent single-point constraints on the grid point. ps(1:6)==true where nodal degrees of freedom are perminantly constrained.
    end
    methods
        function obj = preprocess(obj)
            [nModel,mModel]=size(obj);
            if mModel~=1; error('Function only operates on Model arrays size n x 1.'); end
            for i = 1:nModel
                obj(i) = obj(i).preprocess_sub();
            end
            
            % Superelement connections
            obj = obj(1).superElement.preprocess(obj);
            
            % Preprocess sets
            obj = DofSet.partition(obj);
            
        end
        function obj = assemble(obj)
            % Model assembly, reduction, and synthesis
            [nModel,mModel]=size(obj);
            if mModel~=1; error('Function only operates on Model arrays size n x 1.'); end
            
            % Assemble individual superelements
            for i = 1:nModel
                obj(i) = obj(i).assemble_sub();
            end
            
            % Reduce Part Superelements and add to residual structure
            if nModel > 1
                for i = 2:nModel
                    obj(i).reducedModel = ReducedModel.constructFromModel(obj(i));
                    
                    gIndex0 = obj(i).aSetIndexInGSet0;
                    obj(1).K_gg(gIndex0,gIndex0) = obj(1).K_gg(gIndex0,gIndex0) + obj(i).reducedModel.K_aa;
                    obj(1).M_gg(gIndex0,gIndex0) = obj(1).M_gg(gIndex0,gIndex0) + obj(i).reducedModel.M_aa;
                end
            end
            
            % Reduce residual structure
            obj(1).reducedModel = ReducedModel.constructFromModel(obj(1));
            
%             % Assemble residual structure
%             obj(1) = obj(1).assemble_sub();
%             
%             % Synthesize superelement parts - single level only - modify for multi level
%             if nModel>1
%                 % Assemble and reduce part superelements
%                 seIndex = obj(1).superElementConnections;
%                 % g2tIndex0 = cumsum(obj(1).t); g2tIndex0(~obj(1).t)=0;
%                 for i = 2:nModel
%                     rowIndex = seIndex(:,i)~=0;
%                     gIndex0 = seIndex(rowIndex,1);
%                     gIndexi = seIndex(rowIndex,i);
%                     obji = obj(i);
%                     g2tIndexi = cumsum(obji.t); g2tIndexi(~obji.t)=0;
%                     % tIndex0=g2tIndex0(gIndex0); if any(tIndex0==0); error('Superelement set problem.'); end
%                     tIndexi=g2tIndexi(gIndexi); if any(tIndexi==0); error('Superelement set problem.'); end
%                     obj(1).K_gg(gIndex0,gIndex0) = obj(1).K_gg(gIndex0,gIndex0) + obji.K_aa(tIndexi,tIndexi);
%                     obj(1).M_gg(gIndex0,gIndex0) = obj(1).M_gg(gIndex0,gIndex0) + obji.M_aa(tIndexi,tIndexi);
%                 end
%             end
            
        end
        function solver = expandResult(obj,solver,u_a)
            % Expands solution result
            [nModel,mModel]=size(obj);
            if mModel~=1; error('Function only operates on Model arrays size n x 1.'); end
            
            % Expand residual structure result
            solver(1) = obj(1).expandResult_sub(solver(1),u_a);
            
            % Index superelement ASET from residual structure ASET
            
            if nModel>1
                for i = 2:nModel
                    u_ai = u_a;
                    solver(i) = obj(i).expandResult_sub(solver(i),u_ai);
                end
            end
        end
        function nModes = getNumModes(obj)
            if isempty(obj.caseControl.method); error('No METHOD defined in Case Control section.'); end
            nModes = obj.eigrl(obj.caseControl.method==obj.eigrl(:,1),2);
            if isempty(nModes); error('EIGRL method is undefined. Check case control METHOD ID and bulk data EIGRL ID.'); end
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
            [obj.sb,obj.sd]=obj.spcs.preprocess(obj);
            
            % Process multi-point constraint sets
            % obj.m, obj.n
            
            % preprocess model sets
            obj = obj.dofSet.preprocess(obj);
            
        end
        function obj = assemble_sub(obj)
            % Assemble
            obj = obj.point.assemble(obj);
            obj = obj.element.assemble(obj); % element and global matricies
            obj = obj.load.assemble(obj);
        end
        function solver = expandResult_sub(obj,solver,u_a)
            
            % preallocate
            nVectors = size(u_a,2);
            u_g=zeros(obj.nGdof,nVectors);
            
            % Expand reduced model result to free and independent set
            u_o = obj.reducedModel.expandResult(u_a);
            u_g(obj.a,:) = u_a;
            u_g(obj.o,:) = u_o;
            
            % prescribed DOF
             u_g(obj.s,:) = repmat(obj.sd(obj.s),[1,nVectors]);
            
             % store in solver object
            solver.u_g = u_g;
            solver.u_0 = obj.R_0g*solver.u_g;
            
            % constraint forces
            solver.f_g = zeros(size(solver.u_g));
            solver.f_g(obj.s,:) = obj.K_gg(obj.s,obj.f)*solver.u_g(obj.f,:) + obj.K_gg(obj.s,obj.s)*solver.u_g(obj.s,:);
            solver.f_0 = obj.R_0g*solver.f_g;
            
            % recover and store selected response data at nodes and elements 
            solver = obj.point.recover(solver,obj);
            solver = obj.element.recover(solver,obj);
        end            
    end
end
