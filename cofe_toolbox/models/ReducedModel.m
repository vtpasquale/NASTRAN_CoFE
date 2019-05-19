% Abstract superclass for CoFE reduced models
% ReducedModel interfaces between Model objects and Solver objects
% ReducedModel objects are reduced from the Model GSET
%
% Anthony Ricciardi
%
classdef (Abstract) ReducedModel < matlab.mixin.Heterogeneous
    properties (Abstract)
        K_aa % ([nAdof,nAdof] double - possibly sparse) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] double - possibly sparse) Mass matrix of analysis set
        u_a  % ([nAdof,nModes] double) Analysis set displacements
    end
    methods (Abstract)
        expandResult(obj)
    end
    methods (Sealed = true)
        function obj=expand(obj,u_a)
            [nReducedModel,mReducedModel]=size(obj);
            if mReducedModel~=1; error('Function only operates on ReducedModel arrays size n x 1.'); end
            for i = 1:nReducedModel
                obj(i) = obj(i).expand_sub(obj(i),u_a);
            end
        end
    end
    methods (Sealed = true, Static = true)
        function reducedModel = constructFromModel(model)
            % check input
            [nModel,mModel] = size(model);
            if nModel < 1; error('size(model,1)<1');end
            if mModel ~=1; error('size(model,2)~=1');end
            for m = 1:1:nModel
                if ~any(model(m).o)
                    % All free degrees of freedom retained
                    reducedModel(m) = ReducedModelFull(model(m));
                elseif ~any(model(m).q)
                    % Guyan reduction
                    reducedModel(m) = ReducedModelGuyan(model(m));
                else
                    % Dynamic reduction
                    reducedModel(m) = ReducedModelDynamic(model(m));
                end
            end
        end
    end
end