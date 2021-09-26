% Abstract superclass for rigid elements and multipoint constraints
% Anthony Ricciardi
%
classdef (Abstract) Mpcs < matlab.mixin.Heterogeneous
    
    methods (Abstract)
        obj = preprocess_sub(obj,model) % Process DOF indicies and calculate constraint coefficent matricies
    end
    methods (Sealed=true)
        function model = preprocess(obj,model)
            % Process DOF indicies and calculate constraint coefficent matricies
            model.m = false(model.nGdof,1);
            
            nMpc = size(obj,1);
            for i=1:nMpc
                obj(i)=obj(i).preprocess_sub(model);
                if any(model.m(obj.m))
                    error('Dependent degrees of freedom are overconstrained my multiple MPCs or rigid elements.')
                end
                model.m(obj.m) = true;
            end
            model.n = ~model.m;
            model.mpcs = obj;
        end
        function model = assemble(obj,model)
            % Assemble constraint matricies
            nDependentDof = sum(model.m);
            if nDependentDof > 1
                nIndependentDof = model.nGdof - nDependentDof;
                % Create n set matricies using same dimension as g set so that
                % g set indexing can be used (i.e., The real R_m = R_m(m,m)).
                R_n = spalloc(model.nGdof,model.nGdof,6*nDependentDof);
                R_m = spalloc(model.nGdof,model.nGdof,12*nDependentDof);
                
                % Loop through entries
                nMpc = size(obj,1);
                for i=1:nMpc
                    oi=obj(i);
                    R_n(oi.m,oi.n)= oi.R_n;
                    R_m(oi.m,oi.m)= oi.R_m;
                end
                
                % Calculate constraint matrix
                model.G_m = -R_m(model.m,model.m)\R_n(model.m,model.n);
            else
                model.G_m = [];
            end
            
        end
    end
end

