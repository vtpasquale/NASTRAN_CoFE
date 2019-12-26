% Class for reduced models with all free degrees of freedom retained
%
% Anthony Ricciardi
%
classdef ReducedModelGuyan < ReducedModel
    properties
        K_aa % ([nAdof,nAdof] double - possibly sparse) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] double - possibly sparse) Mass matrix of analysis set
        G_ot % ([nOdof,nTdof] double) Static boundary transformation matrix between the exterior and interior motion

        u_a  % ([nAdof,nModes] double) Analysis set displacements
    end
    methods
        function obj = ReducedModelGuyan(model)
            % Guyan reduction (a.k.a. static condensation)
            K_oo = model.K_gg(model.o,model.o);
            K_ot = model.K_gg(model.o,model.t);
            obj.G_ot = - K_oo\K_ot;
            obj.K_aa = model.K_gg(model.t,model.t) +  K_ot.'* obj.G_ot;
            % Approximate Mass Matrix Reduction
            M_oo = model.M_gg(model.o,model.o);
            M_ot = model.M_gg(model.o,model.t);
            obj.M_aa = model.M_gg(model.t,model.t) +  M_ot.'*obj.G_ot + ...
            obj.G_ot.'*M_ot + obj.G_ot.'*M_oo*obj.G_ot;
        end
        function u_o = expandResult(obj,u_a)
            u_o=obj.G_ot*u_a;
        end
    end
end