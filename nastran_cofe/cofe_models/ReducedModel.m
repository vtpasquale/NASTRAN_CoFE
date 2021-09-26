% Abstract superclass for CoFE reduced models
% ReducedModel interfaces between Model objects and Solver objects
% ReducedModel objects are reduced from the Model GSET

% Anthony Ricciardi
%
classdef (Abstract) ReducedModel
    properties (Abstract)
        K_aa % ([nAdof,nAdof] sparse double) Elastic stiffness matrix of analysis set
        M_aa % ([nAdof,nAdof] sparse double) Mass matrix of analysis set
        u_a  % ([nAdof,nModes] double) Analysis set displacements
        p_a %  ([nAdof,nLoadSets] double) Analysis set load vectors
    end
    methods (Abstract)
        expandResult(obj)
    end
% %     methods (Sealed = true)
% %         function obj=expand(obj,u_a)
% %             [nReducedModel,mReducedModel]=size(obj);
% %             if mReducedModel~=1; error('Function only operates on ReducedModel arrays size n x 1.'); end
% %             for i = 1:nReducedModel
% %                 obj(i) = obj(i).expand_sub(obj(i),u_a);
% %             end
% %         end
% %     end
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