% Class that defines a static analysis.
% Anthony Ricciardi
%
classdef StaticsSolution < Solution
    
    properties        
        displacement
        spcforces
        force
        stress
        strain
        ese
        eke
    end
    properties (Hidden = true)
        u_g
        f_g
    end
    
    methods 
        function obj=solve_sub(obj,model)
            
            % confirm case control index uniqueness
            caseControlIndex = unique([obj.caseControlIndex]);
            if size(caseControlIndex,2)~=1; error('Case control number issue'); end
            
            % Residual structure model and case control
            model0 = model(1);
            caseControl0 = model0.caseControl(caseControlIndex);
            
            % Residual structure analysis matricies
            K_aa = model0.reducedModel.K_aa;
            % M_aa = model0.reducedModel.M_aa;
            p_a = model0.reducedModel.p_a;
                        
            if isempty(caseControl0.load); warning('No load case identification number specified.'); end
            lc = find(caseControl0.load==model0.loadSIDs);
            if isempty(lc); warning('No applied loads found for this case.'); end
            
            % Solve
            u_a = K_aa\p_a(:,lc);
            
            % Calculate Total Energy
            obj = obj.calculateTotalEnergy(K_aa,u_a);
            
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
            hdf5Domains.SE = [];
            
            % Loop over superelements to create vector domains
            for i = 1:nModel
                nVectors = size(obj(i).u_g,2);
                
                obj(i).vectorHdf5DomainID = uint32(startDomainId:startDomainId+nVectors-1)';
                hdf5Domains.ID = [hdf5Domains.ID; obj(i).vectorHdf5DomainID];
                startDomainId = hdf5Domains.ID(end)+1;
                
                hdf5Domains.SUBCASE = [hdf5Domains.SUBCASE;...
                    repmat( model(i).caseControl(obj(i).caseControlIndex(i)).subcase,[nVectors,1])  ];
                
                hdf5Domains.ANALYSIS = [hdf5Domains.ANALYSIS;...
                    repmat( uint32(1) ,[nVectors,1])  ];
                
                hdf5Domains.SE = [hdf5Domains.SE;...
                    repmat( model(i).superElementID,[nVectors,1])  ];
            end
            
            % Fill unused fields
            fillZeros = zeros(size(hdf5Domains.ID,1),1,'uint32');
            hdf5Domains.TIME_FREQ_EIGR = zeros(size(hdf5Domains.ID,1),1,'double');
            hdf5Domains.MODE = fillZeros;
            hdf5Domains.STEP = fillZeros;
            hdf5Domains.EIGI = fillZeros;
            hdf5Domains.DESIGN_CYCLE = fillZeros;
            hdf5Domains.RANDOM = fillZeros;
            hdf5Domains.AFPM = fillZeros;
            hdf5Domains.TRMC = fillZeros;
            hdf5Domains.INSTANCE = fillZeros;
            hdf5Domains.MODULE = fillZeros;
        end
    end
end

