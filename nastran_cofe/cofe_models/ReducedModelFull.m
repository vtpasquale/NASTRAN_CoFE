% Class for reduced models with all free degrees of freedom retained
%
% Anthony Ricciardi
%
classdef ReducedModelFull < ReducedModel
    properties
        K_aa % ([nAdof,nAdof] double - possibly sparse) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] double - possibly sparse) Mass matrix of analysis set
        u_a  % ([nAdof,nModes] double) Analysis set displacements
        p_a %  ([nAdof,nLoadSets] double) Analysis set load vectors
    end
    methods
        function obj = ReducedModelFull(model)
            obj.K_aa = model.K_gg(model.f,model.f);
            obj.M_aa = model.M_gg(model.f,model.f);
            obj.p_a = model.p_g(model.f,:);
        end
        function u_o = expandResult(obj,u_a)
            u_o = [];
        end
    end
end