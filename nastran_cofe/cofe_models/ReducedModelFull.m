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
            obj.K_aa = model.K_nn(model.f,model.f);
            obj.M_aa = model.M_nn(model.f,model.f);
            if any(and(any(model.u_s,2),~model.s))
                error('A global coordinate (Gi and Ci) referenced by an SPCD entry must also be referenced on a SPC or SPC1 Bulk Data entry and selected by the SPC Case Control command.')
            end
            obj.p_a =  model.p_n(model.f,:) - model.K_nn(model.f,model.s)*model.u_s(model.s,:);
        end
        function u_o = expandResult(obj,u_a)
            u_o = [];
        end
    end
end