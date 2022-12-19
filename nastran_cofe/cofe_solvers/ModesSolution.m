% Class that defines a normal modes analysis.
% Anthony Ricciardi
%
classdef ModesSolution < Solution
    
    properties       
        eigenvalueTable
%         displacement
%         spcforces
%         force
%         stress
%         strain
%         ese
%         eke
    end
    properties (Hidden = true)
        u_g
        f_g
        w2 % [nResponseVectors,1 double] eigenvalue for modes solutions (saved seperatly from eigenvalueTable to calculate element kinetic energy inside superelements)
    end
    
    methods
        function obj=solve_sub(obj,model)
            % Normal modes solution
            %
            % INPUTS
            % obj = [1,nSuperElements Solution] Array of Solution objects, one for each superelement
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
            
            % Calculate Total Energy
            obj = obj.calculateTotalEnergy(K_aa,u_a);
            
            % Recover model results
            obj = model.recover(obj,u_a);
        end
        function [modesSolution,hdf5Domains] = solution2Hdf5Domains(modesSolution,model,startDomainId)
            % Convert solution data to Hdf5 domain data and set obj.vectorHdf5DomainID value
            %
            % INPUTS
            % modesSolution = [1,1 ModesSolution] Modes Solution object
            % model = [1,1 Model] Model object
            % startDomainId = [uint32] starting domain ID
            %
            % OUTPUTS
            % obj = [1,1 ModesSolution] ModesSolution objects with vectorHdf5DomainID property set
            % hdf5Domains = [struct] Hdf5Domains fields and properties
            
            % Checks
            [nCase,nModel]=size(modesSolution);
            if nCase~=1; error('Function only operates on Solution size 1 x 1.'); end
            if nModel~=1; error('Function only operates on Solution size 1 x 1.'); end
            if size(model,2)~=1; error('Function only operates on Model size 1 x 1.'); end
            if size(model,1)~=1; error('Function only operates on Model size 1 x 1.'); end
            
            % Initialize empty struct data
            hdf5Domains.ID = [];
            hdf5Domains.SUBCASE = [];
            hdf5Domains.ANALYSIS = [];
            hdf5Domains.TIME_FREQ_EIGR = [];
            hdf5Domains.MODE = [];
            hdf5Domains.SE = [];
            
            nVectors = size(modesSolution.u_g,2);
            
            modesSolution.vectorHdf5DomainID = uint32(startDomainId:startDomainId+nVectors-1)';
            hdf5Domains.ID = [hdf5Domains.ID; modesSolution.vectorHdf5DomainID];
            startDomainId = hdf5Domains.ID(end)+1;
            
            hdf5Domains.SUBCASE = [hdf5Domains.SUBCASE;...
                repmat( model.caseControl(modesSolution.caseControlIndex).subcase,[nVectors,1])  ];
            
            hdf5Domains.ANALYSIS = [hdf5Domains.ANALYSIS;...
                repmat( uint32(2) ,[nVectors,1])  ];
            
            hdf5Domains.TIME_FREQ_EIGR = [hdf5Domains.TIME_FREQ_EIGR;...
                modesSolution.w2];
            
            hdf5Domains.MODE = [hdf5Domains.MODE; uint32(1:nVectors)'];
            
            hdf5Domains.SE = [hdf5Domains.SE;...
                repmat( model.superElementID,[nVectors,1])  ];
            
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
