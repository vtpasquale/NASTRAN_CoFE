% Class for reduced models with all free degrees of freedom retained
%
% Anthony Ricciardi
%
classdef ReducedModelFull < ReducedModel
    properties
        K_aa % ([nAdof,nAdof] sparse double) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] sparse double) Mass matrix of analysis set
        u_a  % ([nAdof,nModes] double) Analysis set displacements
        p_a %  ([nAdof,nLoadSets] double) Analysis set load vectors
    end
    methods
        function obj = ReducedModelFull(model)
            
            % local variables
            nGdof=model.nGdof;
            n = model.n;
            m = model.m;
            G_m = model.G_m;
            
            % Create n set matricies using same dimension as g set so that
            % g set indexing can be used (i.e., The real K_nn = K_nn(n,n)). 
            % This maintains the f set indcies, so K_ff = K_nn(f,f).
            if isempty(model.G_m)
                K_nn = model.K_gg;
                M_nn = model.M_gg;
                p_n = model.p_g;
            else
                K_nn = spalloc(nGdof,nGdof,nnz(model.K_gg));
                M_nn = spalloc(nGdof,nGdof,nnz(model.M_gg));
                K_nn(n,n) = model.K_gg(n,n) +  model.K_gg(n,m)*G_m + G_m.'* model.K_gg(n,m).' + G_m.'* model.K_gg(m,m)*G_m;
                M_nn(n,n) = model.M_gg(n,n) +  model.M_gg(n,m)*G_m + G_m.'* model.M_gg(n,m).' + G_m.'* model.M_gg(m,m)*G_m;
                p_n(n,:) = model.p_g(n,:) + G_m'*model.p_g(m,:);
            end
            
            obj.K_aa = K_nn(model.f,model.f);
            obj.M_aa = M_nn(model.f,model.f);
            if any(and(any(model.u_s,2),~model.s))
                error('A global coordinate (Gi and Ci) referenced by an SPCD entry must also be referenced on a SPC or SPC1 Bulk Data entry and selected by the SPC Case Control command.')
            end
            obj.p_a =  p_n(model.f,:) - K_nn(model.f,model.s)*model.u_s(model.s,:);
        end
        function u_o = expandResult(obj,u_a)
            u_o = [];
        end
    end
end