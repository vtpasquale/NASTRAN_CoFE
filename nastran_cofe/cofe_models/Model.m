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
        % superElementConnections % ([nGdof,nSuperElements] sparse) Superelement connections, exists only in residual structure model
        
        seconctIndexInGSet  % [nSeconctDof,1 uint32] GSET index (in this superelement) of boundary DOF defined by SECONCT
        seconctIndexInGSet0 % [nSeconctDof,1 uint32] GSET index (in residual structure) of boundary DOF defined by SECONCT
        % seconctIndexInASet0 % [nSeconctDof,1 uint32] ASET index (in residual structure) of boundary DOF defined by SECONCT
        
        
        %% Matricies
        K_gg  % ([nGdof,nGdof] sparse) Elastic stiffness matrix in nodal displacement reference frame
        KD_gg % ([nGdof,nGdof] sparse) Differential stiffness matrix in nodal displacement reference frame
        M_gg  % ([nGdof,nGdof] sparse) Mass matrix in nodal displacement reference frame
        G
        p_g % ([nGdof,nLoadSets] double) load vectors in nodal displacement reference frame
        R_0g % ([nGdof,nGdof] sparse) Transformation matrix from nodal displacement reference frame to the basic reference frame
             
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
            obj.load = obj.load.preprocess(obj);
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
            solution.u_g = u_g;
            % solution.u_0 = obj.R_0g*solution.u_g;
            
            % constraint forces
            solution.f_g = zeros(size(solution.u_g));
            if isa(solution,'StaticsSolution')
                solution.f_g(obj.s,:) = obj.K_gg(obj.s,obj.f)*solution.u_g(obj.f,:) ...
                                      + obj.K_gg(obj.s,obj.s)*solution.u_g(obj.s,:);
                                      % - obj.p_g(obj.s,:); TODO - revisit this with load case sorting
            elseif isa(solution,'ModesSolution')
                w2 = repmat(solution.eigenvalueTable.eigenvalue.',[obj.nGdof,1]);
                a_g= -1*w2.*solution.u_g;
                solution.f_g(obj.s,:) = obj.K_gg(obj.s,obj.f)*solution.u_g(obj.f,:) ...
                                      + obj.K_gg(obj.s,obj.s)*solution.u_g(obj.s,:) ...
                                      + obj.M_gg(obj.s,obj.f)*a_g(obj.f,:) ...
                                      + obj.M_gg(obj.s,obj.s)*a_g(obj.s,:);
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
