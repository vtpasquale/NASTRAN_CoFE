% Abstract superclass for CoFE reduced models
% ReducedModel interfaces between Model objects and Solver objects
% ReducedModel objects are reduced from the Model GSET

% Anthony Ricciardi
%
classdef (Abstract) ReducedModel
    properties (Abstract)
        K_aa % ([nAdof,nAdof] sparse double) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] sparse double) Mass matrix of analysis set
        u_a  % ([nAdof,nLoadSets] double) Analysis set displacements for all load cases
        p_a %  ([nAdof,nLoadSets] double) Analysis set load vectors
    end
    properties (Hidden=true,SetAccess=private)
        factorizationType; % [char]
    end
    properties (Access=private) % Matrix Factorization only calculated if/when needed. Stored in case needed again. Access using getUK() method.
        UK % [nAdof,nAdof sparse double] upper triangular matrix.  
        LK % [nAdof,nAdof sparse double] lower triangular matrix. Typcally unused - only used when complex step of the entire solution is needed.
    end
    methods (Abstract)
        expandResult(obj)
    end
    methods (Sealed = true)
        function obj = solveUaAllLoadSets(obj)
            obj.u_a = obj.K_aa\obj.p_a;
        end
        function pseudoLoads = calculateDirectSensitivityPseudoLoad(obj,u_a,dx)
            % Calculates direct sensitivity pseudo loads. This should only
            % be called for complex-assembed ReducedModel objects.
            %
            % Inputs
            % u_a [nAdof,nLoadSets real double] Analysis result displacements for all load cases
            % dx [real double] Complex step size.
            %
            % Outputs
            % pseudoLoads [nAdof,nLoadSets real double] direct sensitivity pseudo loads for all load cases
            pseudoLoads = imag(obj.p_a)./dx - (imag(obj.K_aa)./dx)*u_a;
        end
        function obj = factorizeStiffness(obj)
            if isreal(obj.K_aa)
                obj.UK = chol(obj.K_aa);
                obj.factorizationType = 'chol';
            else
                [obj.LK,obj.UK] = lu(obj.K_aa);
                obj.factorizationType = 'lu';
            end
        end
        function u = forwardaAndBackSubstitution(obj,p)
            switch obj.factorizationType
                case 'chol'
                    u = obj.UK\(obj.UK.'\p);
                case 'lu'
                    u = obj.UK\(obj.LK\p);
                otherwise
                    error('Ensure the stiffness matrix is factorized before calling forwardaAndBackSubstitution().')
            end
        end
    end
    methods (Sealed = true, Static = true)
        function reducedModel = constructFromModel(model)
            % Function creates a reduced model from a model.
            % Does not support multidimensional model arrays.
            %
            % INPUT
            % model [1,1 Model]
            %
            % OUTPUTS
            % reducedModel [1,1 ReducedModel]
            
            % check input
            [nModel,mModel] = size(model);
            if nModel ~= 1; error('size(model,1)~=1');end
            if mModel ~=1; error('size(model,2)~=1');end
            
            if ~any(model.o)
                % All free degrees of freedom retained
                reducedModel = ReducedModelFull(model);
            elseif ~any(model.q)
                % Guyan reduction
                reducedModel = ReducedModelGuyan(model);
            else
                % Dynamic reduction
                reducedModel = ReducedModelDynamic(model);
            end
        end
    end
end