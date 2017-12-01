% Class that defines a finite element model.
% Anthony Ricciardi
classdef model
        
    properties
        %% Model entities
        CORD@cord;
        MAT@mat;
        PROP@prop;
        NODE@node;
        ELEM@elem;
        SPCS@spcs;
%         MPCS@mpcs;
        LOADS@loads;
        
        %% Simple entities
        eigTab=[]; % [:,2 int] table with eigenvalue solver parameters [SID,ND], where SID = Set identification number and ND = number of roots desired.
        
        %% Sets
        sb % ([:,1] int) Degrees-of-freedom eliminated by single-point constraints that are included in boundary conditions
        sg % ([:,1] int) Degrees-of-freedom eliminated by single-point constraints that are specified on the PS field on node entries.
        s  % ([:,1] int) All degrees-of-freedom eliminated by single point constraints -> sb + sg
        f  % ([:,1] int) Unconstrained (free) structural degrees-of-freedom -> a + o 
        m  % ([:,1] int) All degrees-of-freedom eliminated by multiple constraints
        n  % ([:,1] int) All degrees-of-freedom not constrained by multipoint constraints
        
        %% Matricies
        K
        KD
        M
        G
    end
    properties (Hidden=true)
        cordCIDs
        matMIDs
        propPIDs
        nodeIDs
        elemEIDs
        spcsSIDs
        loadsSIDs
        
        node2gdof
        ngdof
    end

    methods
        function obj = preprocess(obj)
            nnodes = size(obj.NODE,1);
            obj.ngdof       = 6*nnodes;
            obj.node2gdof   = zeros(6,nnodes);
            obj.node2gdof(:)= 1:obj.ngdof;
            
            % Preprocess model entities
            obj.CORD = obj.CORD.preprocess();
            obj.MAT  = obj.MAT.preprocess();
            obj.PROP = obj.PROP.preprocess();
            obj.NODE = obj.NODE.preprocess();
            obj.ELEM = obj.ELEM.preprocess();
            
            % Store vectors of ID numbers as seperate varables. This
            % speeds up assembly because concatenation gets expensive.
            obj.cordCIDs=[obj.CORD.CID];
            obj.matMIDs=[obj.MAT.MID];
            obj.propPIDs=[obj.PROP.PID];
            obj.nodeIDs=[obj.NODE.ID];
            obj.elemEIDs=[obj.ELEM.EID];
            obj.spcsSIDs=[obj.SPCS.SID];
            obj.loadsSIDs=[obj.LOADS.SID];
            
            % Process MAT references in PROP entries to speed things up?
            
            % Assemble element and global matricies
            obj = obj.ELEM.assemble_all();
            
            % Process single-point constraints
            obj.sg = obj.NODE.process_ps(); % DOF eliminated by perminant single-point constraints
            % obj.sb = obj.SPCS.process_sb(); % DOF eliminated by boundary single-point constraints
            % obj.s = obj.sg | obj.sb; % All DOF eliminated single-point constraints
            
            
            %% process free degrees of freedom
            obj.f  = ~obj.sb;
        
        end
    end
    
end

