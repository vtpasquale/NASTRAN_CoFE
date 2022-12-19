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
        point=Point.empty(0,1); % Grid points (nodes) and scalar points
        element=Element.empty(0,1);
        spcs@Spcs;
        mpcs@Mpcs;
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
        % superElementConnections % ([nGdof,nSuperElements] sparse) Superelement connections, exists only in residual structure model
        
        seconctIndexInGSet  % [nSeconctDof,1 uint32] GSET index (in this superelement) of boundary DOF defined by SECONCT
        seconctIndexInGSet0 % [nSeconctDof,1 uint32] GSET index (in residual structure) of boundary DOF defined by SECONCT
        % seconctIndexInASet0 % [nSeconctDof,1 uint32] ASET index (in residual structure) of boundary DOF defined by SECONCT
        
        
        %% G set matricies
        K_gg  % ([nGdof,nGdof] sparse double) Elastic stiffness matrix in nodal displacement reference frame
        % KD_gg % ([nGdof,nGdof] sparse double) Differential stiffness matrix in nodal displacement reference frame
        M_gg  % ([nGdof,nGdof] sparse double) Mass matrix in nodal displacement reference frame
        p_g % ([nGdof,nLoadSets] double) load vectors in nodal displacement reference frame
        % R_0g % ([nGdof,nGdof] sparse) Transformation matrix from nodal displacement reference frame to the basic reference frame
        
        %% Multipoint constraint matricies
        G_m % [nNdof,nMdof double] multipoint constraint matrix (u(m,:) = G_m*u(n,:))
        
        % Create n set matricies using same dimension as g set so that
        % g set indexing can be used (i.e., The real K_nn = K_nn(n,n)).
        % This maintains the f set indcies, so K_ff = K_nn(f,f).
        K_nn % ([nGdof,nGdof] sparse double) Elastic stiffness matrix of indepedent set
        % KD_nn % ([nGdof,nGdof] sparse double) Differential stiffness matrix of indepedent set
        M_nn % ([nGdof,nGdof] sparse double) Mass matrix of indepedent set
        p_n %  ([nGdof,nLoadSets] double) Indepedent set load vectors     
        
        %% Single point constraint matrices
        u_s % ([nGdof,nLoadSets] sparse double) Enforced displacement values due to single-point constraints (nonzero values are specified using SPCD entries - which vary by load ID, not constraint ID) 
        
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
        
        % parameters
        coupledMassFlag % [logical] Coupled mass formulation is used if true, lumped mass formulation used otherwise.
        k6rot % [double] Used for the calculation of drilling stiffness
        wtmass % [double] Mass matrix scale factor - applied after assembly
        post % [int32] Postprocess parameter. HDF5 output written if model(1).post < 1.
        
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
                obj(i) = obj(i).mpcPartition();
            end
            
            % Reduce Part Superelements and add to residual structure
            if nModel > 1
                for i = 2:nModel
                    obj(i).reducedModel = ReducedModel.constructFromModel(obj(i));
                    
                    % Connection DOF
                    seconct0 = obj(i).seconctIndexInGSet0;
                    seconcti = obj(i).seconctIndexInGSet;
                    % obj(i).reducedModel.K_aa is sorted, so sort seconct0
                    % according to seconcti
                    [~,connectIndex] = sort(seconcti);
                    seconct = seconct0(connectIndex);
                    if size(seconct,1)~=size(obj(i).reducedModel.K_aa,1); error('There is an issue with superelement sets'); end
                    
                    % Add superelement to residual structure
                    obj(1).K_gg(seconct,seconct) = obj(1).K_gg(seconct,seconct) + obj(i).reducedModel.K_aa;
                    obj(1).M_gg(seconct,seconct) = obj(1).M_gg(seconct,seconct) + obj(i).reducedModel.M_aa;
                end
            end
            
            % Reduce residual structure
            obj(1).reducedModel = ReducedModel.constructFromModel(obj(1));
            
        end
        function KD_aa = assembleDifferentialStiffness(obj,staticsSolution)
            % Assembles differential stiffness matrix for a single static solution.
            % Not compatible with superelements or dynamically reduced models.
            
            % Input checks
            [nModel,mModel]=size(obj);
            if any([mModel~=1,nModel~=1]); error('Buckling analysis not supported with superelements'); end
            if any(obj.o); error('Buckling analysis not supported for dynamically reduced models'); end
            
            % Assemble g set
            KD_ggTriplet = SparseTriplet(20*obj.nGdof);
            elem = obj.element;
            nElement = size(elem,1);
            for i=1:nElement
                ei=elem(i);
                kd_e=ei.assembleKD(obj,staticsSolution);
                kd_g = ei.R_eg.'*kd_e*ei.R_eg;
                gDof = ei.gdof;
                KD_ggTriplet = KD_ggTriplet.addMatrix(kd_g,gDof);
            end
            KD_gg=KD_ggTriplet.convertToSparseMatrix(obj.nGdof,obj.nGdof);
            
            % Partition n set
            if isempty(obj.G_m)
                KD_nn = KD_gg;
            else
                % concise local variables without class properties name overlap
                nG=obj.nGdof;
                N = obj.n;
                M = obj.m;
                Gm = obj.G_m;
                
                % initialize            
                KD_nn = spalloc(nG,nG,nnz(obj.KD_gg));
                
                % partition
                KD_nn(N,N) = KD_gg(N,N) +  KD_gg(N,M)*Gm + Gm.'* KD_gg(N,M).' + Gm.'* KD_gg(M,M)*Gm;               
            end
            
            % Partition a set
            KD_aa = KD_nn(obj.f,obj.f);
                        
        end
        function obj = mpcPartition(obj)
            % Multipoint constraint partitioning
            
            % Create n set matricies using same dimension as g set so that
            % g set indexing can be used (i.e., The real K_nn = K_nn(n,n)).
            % This maintains the f set indcies, so K_ff = K_nn(f,f).
            if isempty(obj.G_m)
                obj.K_nn = obj.K_gg;
                obj.M_nn = obj.M_gg;
                obj.p_n  = obj.p_g; %  ... % Applied forces - obj.K_nn(:,obj.s)*obj.u_s(obj.s,:);  % Enforced displacements
            else
                % concise local variables without class properties name overlap
                nG=obj.nGdof;
                N = obj.n;
                M = obj.m;
                Gm = obj.G_m;
                
                % initialize            
                obj.K_nn = spalloc(nG,nG,nnz(obj.K_gg));
                obj.M_nn = spalloc(nG,nG,nnz(obj.M_gg));
                obj.p_n  = zeros(size(obj.p_g));
                
                % partition
                obj.K_nn(N,N) = obj.K_gg(N,N) +  obj.K_gg(N,M)*Gm + Gm.'* obj.K_gg(N,M).' + Gm.'* obj.K_gg(M,M)*Gm;
                obj.M_nn(N,N) = obj.M_gg(N,N) +  obj.M_gg(N,M)*Gm + Gm.'* obj.M_gg(N,M).' + Gm.'* obj.M_gg(M,M)*Gm;
                obj.p_n(N,:)  = obj.p_g(N,:) + Gm'*obj.p_g(M,:); % Applied forces
            end            
            
        end
        function solution = recover(obj,solution,u_a)
            % Function to recover solution quantities from ASET solution.
            % This method is called once for all superelements speratly but
            % seperatly for each subcase.
            %
            % INPUTS
            % obj = [nSuperElements,1 Model] Array of Model objects, one for each superelement
            % solution = [1,nSuperElements Solution] Array of Solution objects, one for each superelement
            % u_a = [nAset,nVectors] ASET displacement vectors
            %
            % OUTPUT
            % solution = [1,nSuperElements Solution] Array of Solution objects with recovered output data
            
            % Checks
            [nModel,mModel]=size(obj);
            if mModel~=1; error('Function only operates on Model arrays size n x 1.'); end
            if size(solution,1)~=1; error('Function only operates on Solution arrays size 1 x n.'); end
                        
            % Expand residual structure result
            solution(1) = obj(1).recover_sub(solution(1),u_a);
                      
            % Expand superelement results
            if nModel>1
                for i = 2:nModel
                    
                    % Connection DOF - This is repeat code, update
                    % properties to store seconct 
                    seconct0 = obj(i).seconctIndexInGSet0;
                    seconcti = obj(i).seconctIndexInGSet;
                    % obj(i).reducedModel.K_aa is sorted, so sort seconct0
                    % according to seconcti
                    [~,connectIndex] = sort(seconcti);
                    seconct = seconct0(connectIndex);
                    if size(seconct,1)~=size(obj(i).reducedModel.K_aa,1); error('There is an issue with superelement sets'); end
                    
                    u_ai = solution(1).u_g(seconct,:);
                    solution(i) = obj(i).recover_sub(solution(i),u_ai);
                end
            end
        end
        function nModes = getNumModes(obj,caseControlIndex)
            if isempty(obj.caseControl(caseControlIndex).method); error('No METHOD defined in Case Control section.'); end
            if isempty(obj.eigrl); error('No EIGRL entry defined in Bulk Data section.'); end
            if size(unique(obj.eigrl(:,1)),1)~=size(obj.eigrl(:,1),1); error('EIGRL SID fields must be unique.'); end
            nModes = obj.eigrl(obj.caseControl(caseControlIndex).method==obj.eigrl(:,1),2);
            if isempty(nModes); error('EIGRL method is undefined. Check case control METHOD ID and bulk data EIGRL ID.'); end
        end
        
        function hdf5Domains = model2Hdf5Domains(obj)
            % Convert model data to base (subcase 0) Hdf5 domain data
            %
            % INPUTS
            % obj = [nSuperElements,1 Model] Array of Model objects, one for each superelement
            %
            % OUTPUTS
            % hdf5Domains = [struct] Hdf5Domains fields and properties
            nModel = size(obj,1);
            
            
            % Initialize empty struct data
            hdf5Domains.ID = [];
            hdf5Domains.SE = [];
            
            % Loop over superelements to create base domain
            domainId = 1;
            for i = 2:nModel
                hdf5Domains.ID = [hdf5Domains.ID; uint32(domainId)]; 
                domainId = domainId + 1;
                hdf5Domains.SE = [hdf5Domains.SE; obj(i).superElementID];
            end
            
            % create residual structure base domain last
            i = 1;
            hdf5Domains.ID = [hdf5Domains.ID; uint32(domainId)];
            hdf5Domains.SE = [hdf5Domains.SE; obj(i).superElementID];
            
            % Fill unused fields
            fillZeros = zeros(size(hdf5Domains.ID,1),1,'uint32');
            hdf5Domains.SUBCASE = fillZeros; 
            hdf5Domains.ANALYSIS = fillZeros; 
            hdf5Domains.TIME_FREQ_EIGR = zeros(size(hdf5Domains.ID,1),1,'double');
            hdf5Domains.MODE = fillZeros;
            hdf5Domains.STEP = fillZeros;
            hdf5Domains.EIGI = zeros(size(hdf5Domains.ID,1),1,'double');
            hdf5Domains.DESIGN_CYCLE = fillZeros;
            hdf5Domains.RANDOM = fillZeros;
            hdf5Domains.AFPM = fillZeros;
            hdf5Domains.TRMC = fillZeros;
            hdf5Domains.INSTANCE = fillZeros;
            hdf5Domains.MODULE = fillZeros;
            
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
            
            % Process single-point constraint sets
            obj.sg = obj.point.getPerminantSinglePointConstraints(obj);
            obj.sb = obj.spcs.preprocess(obj);
            
            % Process multi-point constraint sets
            obj = obj.mpcs.preprocess(obj);
            
            % preprocess model sets
            obj = obj.dofSet.preprocess(obj);
            
        end
        function obj = assemble_sub(obj)
            % Assemble
            % obj = obj.point.assemble(obj); % skip - R_0g unused
            obj = obj.element.assemble(obj);
            obj = obj.mpcs.assemble(obj);
            obj = obj.load.assemble(obj);
        end
        function solution = recover_sub(obj,solution,u_a)
            % Function to recover solution quantities from ASET solution.
            % This method is called speratly for each superelement and
            % seperatly for each subcase.
            %
            % INPUTS
            % obj = [1,1 Model]
            % solution = [1,1 Solution] Solution object without recovered output data
            % u_a = [nAset,nVectors] ASET displacement vectors
            %
            % OUTPUT
            % solution = [1,1 Solution] Solution object with recovered output data
            
            % Checks
            if length(obj)~=1; error('Function is intended length(obj)==1 input.'); end
            if length(solution)~=1; error('Function is intended length(solution)==1 input.'); end
            nVectors = size(u_a,2);
            
            % % % Displacement expansion
            u_g=zeros(obj.nGdof,nVectors);
            %
            % Analysis DOF
            u_g(obj.a,:) = u_a;
            %
            % Omitted DOF - from model reduction
            u_o = obj.reducedModel.expandResult(u_a);
            u_g(obj.o,:) = u_o;
            %
            % Prescribed DOF - from single point constraints
            if isa(solution,'StaticsSolution')
                u_g(obj.s,:) = obj.u_s(obj.s,solution.loadCaseIndex);
            elseif isa(solution,'ModesSolution')
                % u_g(obj.s,:) = 0; -- as preallocated
            elseif isa(solution,'BuckSolution')
                % u_g(obj.s,:) = 0; -- as preallocated
            else
                error('Update for new solution')
            end
            %
            % Dependent DOF - from multipoint constraints
            if ~isempty(obj.G_m)
                u_g(obj.m,:) = obj.G_m*u_g(obj.n,:);
            end
            %
            % Store in solver object
            solution.u_g = u_g;

            % % % Constraint expansion
            solution.f_g=zeros(obj.nGdof,nVectors);
            if isa(solution,'StaticsSolution')
                solution.f_g(obj.s,:) = ...
                      obj.K_nn(obj.s,obj.f)*solution.u_g(obj.f,:) ...
                    + obj.K_nn(obj.s,obj.s)*solution.u_g(obj.s,:) ...
                    - obj.p_n(obj.s,solution.loadCaseIndex);
            elseif isa(solution,'ModesSolution')
                w2 = repmat(solution.eigenvalueTable.eigenvalue.',[obj.nGdof,1]);
                a_g= -1*w2.*solution.u_g;
                solution.f_g(obj.s,:) = obj.K_gg(obj.s,obj.f)*solution.u_g(obj.f,:) ...
                    + obj.K_gg(obj.s,obj.s)*solution.u_g(obj.s,:) ...
                    + obj.M_gg(obj.s,obj.f)*a_g(obj.f,:) ...
                    + obj.M_gg(obj.s,obj.s)*a_g(obj.s,:);
            elseif isa(solution,'BuckSolution')
                warning('Constraint forces not recovered for buckling eigenvectors')
            else
                error('Update for new solution')
            end
            
            % recover and store selected response data at elements
            solution = obj.point.recover(solution,obj);
            
            % recover and store selected response data at elements
            if ~isempty(obj.element) % can be empty in superelement analysis
                solution = obj.element.recover(solution,obj);
            end
        end
    end
end
