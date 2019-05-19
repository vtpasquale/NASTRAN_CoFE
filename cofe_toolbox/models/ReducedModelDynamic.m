% Class for reduced models with all free degrees of freedom retained
%
% Anthony Ricciardi
%
classdef ReducedModelDynamic < ReducedModel
    properties
        K_aa % ([nAdof,nAdof] double - possibly sparse) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] double - possibly sparse) Mass matrix of analysis set
        G_ot % ([nOdof,nTdof] double) Static boundary transformation matrix between the exterior and interior motion
        G_oq % ([nOdof,nQdof] double) Dynamic transformation matrix between the exterior and interior motion
        tIndexInA
        qIndexInA

        u_a  % ([nAdof,nModes] double) Analysis set displacements
    end
    methods
        function obj = ReducedModelDynamic(model)
            nModes = getNumModes(model);
                        
            % Start with H\CB only
            K_oo = model.K_gg(model.o,model.o);
            K_ot = model.K_gg(model.o,model.t);
            obj.G_ot = - K_oo\K_ot;
            M_oo = model.M_gg(model.o,model.o);
            [V,D] = eigs(M_oo,K_oo,nModes); % -> (1/w^2) * K * V = M * V is more reliable than K * V = w^2 * M * V
            eigenvalues = diag(D).^-1;

            % Sort by eigenvalue (eigs() does not always return sorted eigenvalues and eigenvectors)
            [eigenvalues,index]=sort(eigenvalues);
            V = V(:,index);
            % mass normalize eigenvectors
            nOset = sum(model.o);
            V = V./repmat(sqrt(diag(V.'*M_oo*V)).',[nOset,1]);
            
            % eigenvalueTable = EigenvalueTable(eigenvalues,diag(V.'*M_oo*V),diag(V.'*K_oo*V)); eigenvalueTable.echo(1)
            
            %
            % Update for QSET definition
            %
            nModesOut = size(V,2);
            nQset = sum(model.q);
            if nModesOut > nQset
                warning('%d MODES CALCULATED BUT ONLY %d QSET DOF DEFINED FOR SUPERELEMENT %d. ADDITIONAL MODES WILL BE DISCARDED.',nModesOut,nQset,model.superElementID)
                V = V(:,1:nQset);
            elseif nModesOut == nQset
                % No adjustment
            else
                error('Not enough modes requested to define QSET DOF.')
                % TODO: check Nastran behavior here
            end            
            obj.G_oq = V;
            nTset = size(obj.G_ot,2);

            % Set Indexing
            aIndex = cumsum(model.a);
            aIndex(~model.a) = 0;
            obj.tIndexInA = aIndex(model.t);
            obj.qIndexInA = aIndex(model.q); 
            if any(obj.tIndexInA==0) || any(obj.qIndexInA==0)
                error('There is a problem with sets. TSET and QSET should be a subset of ASET.')
            end
            
            % Partition for t set and o set indexing...
            K = [model.K_gg(model.o,model.o),model.K_gg(model.o,model.t);
                 model.K_gg(model.t,model.o),model.K_gg(model.t,model.t)];
            M = [model.M_gg(model.o,model.o),model.M_gg(model.o,model.t);
                 model.M_gg(model.t,model.o),model.M_gg(model.t,model.t)];
            T =[obj.G_ot,obj.G_oq;eye(nTset),zeros(nTset,nQset)];

            % Calculate reduced matrices
            K_aa = T.'*K*T;
            M_aa = T.'*M*T;
            
            % Reorder reduced matrices and store in object
            nTQ = nTset + nQset;
            qi = (nTset+1):nTQ;
            ti = 1:nTset;
            obj.K_aa = zeros(nTQ,nTQ);
            obj.K_aa(obj.tIndexInA,obj.tIndexInA) = K_aa(ti,ti);
            obj.K_aa(obj.qIndexInA,obj.qIndexInA) = K_aa(qi,qi);
            obj.K_aa(obj.qIndexInA,obj.tIndexInA) = K_aa(qi,ti);
            obj.K_aa(obj.tIndexInA,obj.qIndexInA) = K_aa(ti,qi);
            obj.M_aa = zeros(nTQ,nTQ);
            obj.M_aa(obj.tIndexInA,obj.tIndexInA) = M_aa(ti,ti);
            obj.M_aa(obj.qIndexInA,obj.qIndexInA) = M_aa(qi,qi);
            obj.M_aa(obj.qIndexInA,obj.tIndexInA) = M_aa(qi,ti);
            obj.M_aa(obj.tIndexInA,obj.qIndexInA) = M_aa(ti,qi);
        end
        function u_o = expandResult(obj,u_a)
            u_t = u_a(obj.tIndexInA,:);
            u_q = u_a(obj.qIndexInA,:);
            u_o = obj.G_ot*u_t + obj.G_oq*u_q;
        end
    end
end