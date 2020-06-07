% Class that defines a normal modes analysis.
% Anthony Ricciardi
%
classdef ModesSolution < Solution
    
    properties
        u_g
        f_g
        
        eigenvalueTable
        
        displacement
        %         velocity
        %         acceleration
        spcforces
        
        force
        stress
        strain
        ese
    
    end
    
    methods
        function obj=solve_sub(obj,model)
            % Normal modes solution
            %
            % INPUTS
            % obj = [1,nSuperElements ModesSolver] Array of ModesSolver objects, one for each superelement
            % model = [nSuperElements,1 Model] Array of Model objects, one for each superelement
            
            % Checks
            if size(model,2)~=1; error('Function only operates on Model arrays size n x 1.'); end
            if size(obj,1)~=1; error('Function only operates on Solution arrays size 1 x n.'); end
            
            % process EIGRL input
            nModes = model(1).getNumModes(obj(1).caseControlIndex);
            
            % Residual structure analysis matricies
            K_aa = model(1).reducedModel.K_aa;
            M_aa = model(1).reducedModel.M_aa;
            
            % Check sets
            nAset = size(K_aa,1);
            if nModes>nAset
                nModes=nAset;
                warning('The number of modes requested by the EIGRL input is larger than the analysis set - the number of modes output will be less than requested.')
            end
            
            % Solve
            [u_a,D] = eigs(M_aa,K_aa,nModes); % -> (1/w^2) * K * V = M * V is more reliable than K * V = w^2 * M * V
            eigenvalues = diag(D).^-1;
            
            % Sort by eigenvalue (eigs() does not always return sorted eigenvalues and eigenvectors)
            [eigenvalues,index]=sort(eigenvalues);
            u_a = u_a(:,index);
            
            % Mass normalize eigenvectors
            u_a = u_a./repmat(sqrt(diag(u_a.'*M_aa*u_a)).',[nAset,1]);
            
            % Store Eigenvalue table
            obj(1).eigenvalueTable = EigenvalueTable(eigenvalues,diag(u_a.'*M_aa*u_a),diag(u_a.'*K_aa*u_a));
            
            % Recover model results
            obj = model.recover(obj,u_a);
        end
        function [obj,hdf5Domains] = solution2Hdf5Domains(obj,model,startDomainId)
            % Convert solution data to Hdf5 domain data and set obj.baseHdf5DomainID & obj.vectorHdf5DomainID values
            %
            % INPUTS
            % obj = [1,nSuperElements ModesSolver] Array of ModesSolver objects, one for each superelement
            % model = [nSuperElements,1 Model] Array of Model objects, one for each superelement
            % startDomainId = [uint32] starting domain ID
            %
            % OUTPUTS
            % obj = [1,nSuperElements ModesSolver] Array of ModesSolver objects, one for each superelement
            % hdf5Domains = [struct] Hdf5Domains fields and properties
            
            % Checks
            [nCase,nModel]=size(obj);
            if nCase~=1; error('Function only operates on Solution arrays size 1 x n.'); end
            if size(model,2)~=1; error('Function only operates on Model arrays size n x 1.'); end
            if size(model,1)~=nModel; error('size(obj,2)~=size(model,1)'); end
            
            % Initialize empty struct data
            hdf5Domains.ID = [];
            hdf5Domains.SUBCASE = [];
            hdf5Domains.ANALYSIS = [];
            hdf5Domains.TIME_FREQ_EIGR = [];
            hdf5Domains.MODE = [];
            hdf5Domains.SE = [];
                        
            % Loop over superelements to create vector domains
            for i = 1:nModel
                nVectors = size(obj(i).u_g,2);
                
                obj(i).vectorHdf5DomainID = uint32(startDomainId:startDomainId+nVectors-1)';
                hdf5Domains.ID = [hdf5Domains.ID; obj(i).vectorHdf5DomainID];
                startDomainId = hdf5Domains.ID(end)+1;
                
                hdf5Domains.SUBCASE = [hdf5Domains.SUBCASE;...
                    repmat( model(i).caseControl(obj(i).caseControlIndex).subcase,[nVectors,1])  ];
                
                hdf5Domains.ANALYSIS = [hdf5Domains.ANALYSIS;...
                    repmat( uint32(2) ,[nVectors,1])  ];
                
                hdf5Domains.TIME_FREQ_EIGR = [hdf5Domains.TIME_FREQ_EIGR;...
                    obj(1).eigenvalueTable.eigenvalue];
                
                hdf5Domains.MODE = [hdf5Domains.MODE; uint32(1:nVectors)'];
                
                hdf5Domains.SE = [hdf5Domains.SE;...
                    repmat( model(i).superElementID,[nVectors,1])  ];
            end
            
            % Fill unused fields
            fillZeros = zeros(size(hdf5Domains.ID,1),1,'uint32');
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
end
