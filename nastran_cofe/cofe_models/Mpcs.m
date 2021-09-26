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
            nCheck  = false(model.nGdof,1);
            model.m = false(model.nGdof,1);
            
            nMpc = size(obj,1);
            for i=1:nMpc
                obj(i)=obj(i).preprocess_sub(model);
                nCheck(obj.n)  = true;
                model.m(obj.m) = true;
                keyboard
                
            end
            if any((~model.n) ~= model.m)
                error('Multipoint constraint issue. Check independent DOF on RBE2 and RBE3 elements.')
            end
            model.mpcs = obj;
            
        end
        function model = assemble(obj,model)
            % Assemble constraint matricies
            nDependentDof = sum(model.m);
            nIndependentDof = model.nGdof - nDependentDof;
            R_n = spalloc(nDependentDof,nIndependentDof,6*nDependentDof);
            R_m = spalloc(nDependentDof,nDependentDof,12*nDependentDof);

            % Loop through entries
            nMpc = size(obj,1);
            for i=1:nMpc
                oi=obj(i);
                keyboard
                R_n(oi.m,oi.n)= oi.R_n;
                R_m(oi.m,oi.m)= oi.R_m;
            end
            
            % Calculate constraint matrix
            model.G_m = -R_m\R_n;
        end
    end
end

