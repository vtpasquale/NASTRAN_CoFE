% Class for RBE3 elements
% Anthony Ricciardi
%
classdef Rbe3 < Mpcs
    
    properties
        eid % [uint32] Element identification number.
        refgrid  % [uint32] Reference grid point identification number.
        refc  % [nComponents,1 uint32] Component numbers at the reference grid point. (Integers 1 through 6 with no embedded blanks.)
        % wt1 % [double] Relative weighting factor for components of motion on the following entry at grid points G1,j. This value does not affect the solution because the user is limited to a single relative weighting factor.
        c1  % [nComponents,1 uint32] Component numbers with weighting factor WT1 at grid points G1,j. (Integers 1 through 6 with no embedded blanks.)
        g1  % [1,nIndependentNodes uint32] Grid points with components C1 that have weighting factor WT1 in the averaging equations.
    end
    
    properties (SetAccess = private)
        n % [nIndependentDof,1 uint32] Independent DOF indices in g set
        m % [nDependentDof,1 uint32] Dependent DOF indices in g set
        R_n % [nDependentDof,1-6 double] Independent DOF constraint coefficent matrix
        R_m % [nDependentDof,nDependentDof double] Dependent DOF constraint coefficent matrix
    end
    
    methods
        function obj = preprocess_sub(obj,model)
            nIndependentNodes = size(obj.g1,2);
            
            % Nodes
            mSetNode = model.point.getNode(obj.refgrid,model);
            nSetNode = model.point.getPoints(obj.g1.',model);
            if ~isa(nSetNode,'Node')
                error('RBE3 EID = %d has a G1 field that references a scalar point.',obj.eid);
            end        
            
            % Dependent DOF indices and transformation
            obj.m = mSetNode.gdof(obj.refc).';
            T_m0  = mSetNode.T_g0;

            % All 6 DOF indices for each node with independent DOF
            nSetNodesGdof = [nSetNode.gdof];
            nSetNodesGdofColumns = zeros(6,nIndependentNodes,'uint32');
            nSetNodesGdofColumns(:) = nSetNodesGdof;
                        
            % Independent DOF global indices
            nSetDofColumns = nSetNodesGdofColumns(obj.c1,:);
            obj.n = nSetDofColumns(:);
            
            % Independent DOF element indices
            nSetNodesElementIndexColumns = zeros(6,nIndependentNodes,'uint32');
            nSetNodesElementIndexColumns(:) = uint32(1:nIndependentNodes*6);
            nElementDofColumns = nSetNodesElementIndexColumns(obj.c1,:);
            nElementDof = nElementDofColumns(:);            
            
            % Assemble element matrices
            S = zeros(6*nIndependentNodes,6);
            Ell = zeros(nIndependentNodes,1);
            for i = 1:nIndependentNodes
                
                % Transformation matrix to n set reference frame
                T_n0 = nSetNode(i).T_g0;
                T_nm = T_n0*T_m0.';
                
                % 6DOF Transformation matrix
                R_nm = zeros(6);
                R_nm(1:3,1:3) = T_nm;
                R_nm(4:6,4:6) = T_nm;
                
                % Relative location expressed in n reference frame
                d = T_n0*( nSetNode(i).x_0 - mSetNode.x_0 );
                Ell(i) = normCS(d);
                
                % Kinematic matrix
                index = (1:6)+6*(i-1);
                S(index,:) = [1     0     0     0     d(3) -d(2)
                              0     1     0    -d(3)  0     d(1)
                              0     0     1     d(2) -d(1)  0
                              0     0     0     1     0     0
                              0     0     0     0     1     0
                              0     0     0     0     0     1   ]*R_nm;
            end

            % Uniform dimensionalization and scaling matrix
            ell = sum(Ell)/nIndependentNodes;
            W6 = diag( repmat([1;1;1;ell;ell;ell],[nIndependentNodes,1]) );
            
            % Right hand side matrix
            Z6 = W6*S;
                        
            % Reduce to relevant independent DOF
            W = W6(nElementDof,nElementDof);
            Z = Z6(nElementDof,:);
            
            % Singularity check
            A = Z.'*Z;
            if rank(A) < size(A,1)
                error('Numerical analysis predicts a mechanism in RBE3 ID %d.  Additional DOF in C1 may stabalize the element.',obj.eid);
            end
            
            % Least-squares solution for constraint matrix (includes extra dependent DOF)
            G_m6 = A\Z.'*W;
            
            % Reduce to relavent dependent DOF
            G_m = G_m6(obj.refc,:);
            
            % Save constraint coefficent matrices
            obj.R_n =  G_m;
            obj.R_m = -1*eye(size(obj.R_n,1));
        end
    end
end
