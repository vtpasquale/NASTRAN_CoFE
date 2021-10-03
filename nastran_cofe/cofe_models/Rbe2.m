% Class for RBE2 elements
% Anthony Ricciardi
%
classdef Rbe2 < Mpcs
    
    properties
        eid % [uint32] Element identification number.
        gn  % [uint32] Identification number of grid point to which all six independent degrees-of freedom for the element are assigned.
        cm  % [nComponents,1 uint32] Component numbers of the dependent degrees-of-freedom in the global coordinate system at grid points GMi. (Integers 1 through 6 with no embedded blanks.)
        gm  % [nDependentNodes,1 uint32] Grid point identification numbers at which dependent degrees-of-freedom are assigned.
    end
    
    properties (SetAccess = private)
        n % [6,1 uint32] Independent DOF indices in g set
        m % [nDependentDof,1 uint32] Dependent DOF indices in g set
        R_n % [nDependentDof,6 double] Independent DOF constraint coefficent matrix
        R_m % [nDependentDof,nDependentDof double] Dependent DOF constraint coefficent matrix
    end
    
    methods
        function obj = preprocess_sub(obj,model)
            nDependentNodes = size(obj.gm,2);
            % nDependentDof = size(obj.cm,1)*nDependentNodes;
            
            % Nodes
            nSetNode = model.point.getNode(obj.gn,model);
            mSetNode = model.point.getPoints(obj.gm.',model);
            if ~isa(mSetNode,'Node')
                error('RBE2 EID = %d has a GMi field that references a scalar point.',obj.eid);
            end        
            
            % Independent DOF indices and constraint coefficent matrix
            obj.n = nSetNode.gdof.';
            T_0n = zeros(6);
            T_0n(1:3,1:3) = nSetNode.T_g0.';
            T_0n(4:6,4:6) = T_0n(1:3,1:3);
            % R_n6 = repmat(eye(6)*T_0n,[nDependentNodes,1]);
            R_n6 = zeros(6*nDependentNodes,6);

            % All 6 DOF indices for each node with dependent DOF
            mSetNodesGdof = [mSetNode.gdof];
            mSetNodesGdofColumns = zeros(6,nDependentNodes,'uint32');
            mSetNodesGdofColumns(:) = mSetNodesGdof;
                        
            % Dependent DOF global indices
            mSetDofColumns = mSetNodesGdofColumns(obj.cm,:);
            obj.m = mSetDofColumns(:);
            
            % Dependent DOF element indices
            mSetNodesElementIndexColumns = zeros(6,nDependentNodes,'uint32');
            mSetNodesElementIndexColumns(:) = uint32(1:nDependentNodes*6);
            mElementDofColumns = mSetNodesElementIndexColumns(obj.cm,:);
            mElementDof = mElementDofColumns(:);            
            
            % Assemble dependent DOF constraint coefficent matrix
            R_m6 = zeros(nDependentNodes*6);
            for i = 1:nDependentNodes
                
                % Relative location
                r = mSetNode(i).x_0 - nSetNode.x_0;
                
                % Transformation matrix
                T_0m = zeros(6);
                T_0m(1:3,1:3) = mSetNode(i).T_g0.';
                T_0m(4:6,4:6) = T_0m(1:3,1:3);
                
                index = (1:6)+6*(i-1);
                R_n6(index,:) = ...
                -1*[1     0     0     0     r(3) -r(2)
                    0     1     0    -r(3)  0     r(1)
                    0     0     1     r(2) -r(1)  0
                    0     0     0     1     0     0
                    0     0     0     0     1     0
                    0     0     0     0     0     1   ]*T_0n;
                R_m6(index,index) = eye(6)*T_0m;
                
            end
            
            % Partition to only dependent DOF
            obj.R_n = R_n6(mElementDof,:);
            obj.R_m = R_m6(mElementDof,mElementDof);
            
        end
    end
end
