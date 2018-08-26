% Abstract superclass for elastic elements
% Anthony Ricciardi
%
classdef (Abstract) elem < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        EID % [int] Element identification number.
        G % [1,: int] Node identification numbers of connection points.
        gdof % [ngdof,1 int] Indices of of element degrees of freedom in global set
    end
    properties (Abstract=true,Hidden=true)
        elem_type % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
    end
    methods (Abstract)
        obj = assemble(obj,MODEL) % Calculate element matricies
        obj = recover_sub(obj,u_g) % Recover element response values
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % preprocess elements
            [nelem,m] = size(obj);
            if m > 1; error('elem.preprocess() can only handel nx1 arrays of elem objects. The second dimension exceeds 1.'); end
            
            % check that element id numbers are unique
            EIDS=[obj.EID];
            
            [~,ia] = unique(EIDS,'stable');
            if size(ia,1)~=nelem
                nonunique=setxor(ia,1:nelem);
                error('Element identification numbers should be unique. Nonunique element identification number(s): %s',sprintf('%d,',EIDS(nonunique)))
            end
        end
        function MODEL = assemble_all(obj,MODEL)
            % assemble element and global matricies
            
            % Preallocate Sparse Matrices
            K_g = spalloc(MODEL.ngdof,MODEL.ngdof,20*MODEL.ngdof);
            M_g = K_g;
            
            % Loop through elements
            nelem = size(obj,1);
            for i=1:nelem
                oi=obj(i).assemble(MODEL);
                K_g(oi.gdof,oi.gdof)=K_g(oi.gdof,oi.gdof)+oi.R_eg.'*oi.k_e*oi.R_eg;
                M_g(oi.gdof,oi.gdof)=M_g(oi.gdof,oi.gdof)+oi.R_eg.'*oi.m_e*oi.R_eg;
                obj(i)=oi;
            end
            MODEL.ELEM=obj;
            MODEL.K_g=K_g;
            MODEL.M_g=M_g;
        end
        function SOLUTION = recover(obj,SOLUTION)
            nelem = size(obj,1);
            IDs = uint32([obj.EID]).';
            
            % returnIO [nelem,4] [force,stress,strain,strain_energy]
            returnIO = false(nelem,4);
            returnIO(...
                SOLUTION.CASE_CONTROL.FORCE.get_member_ID_indices(IDs,SOLUTION.CASE_CONTROL.OUTPUT_SETS),...
                1) = true;
            returnIO(...
                SOLUTION.CASE_CONTROL.STRESS.get_member_ID_indices(IDs,SOLUTION.CASE_CONTROL.OUTPUT_SETS),...
                1) = true;
            returnIO(...
                SOLUTION.CASE_CONTROL.STRAIN.get_member_ID_indices(IDs,SOLUTION.CASE_CONTROL.OUTPUT_SETS),...
                1) = true;
            returnIO(...
                SOLUTION.CASE_CONTROL.ESE.get_member_ID_indices(IDs,SOLUTION.CASE_CONTROL.OUTPUT_SETS),...
                1) = true;
            
            % Any element indices where element results are requested
            recoverIND = uint32(find(any(returnIO,2)));
            
            % preallocate element_output_data objects
            % s(nstress,1) = element_output_data();
            u_g = SOLUTION.u_g;
            F = [];
            S = [];
            E = [];
            ESE = [];
            for i = 1:size(recoverIND,1)
                ele_ind = recoverIND(i);
                oi = obj(ele_ind);
                [f,s,e,ese] = oi.recover_sub(u_g,returnIO(ele_ind,:));
                if ~isempty(f)
                    F = [F;element_output_data(oi.EID,oi.elem_type,1,f)];
                end
                if ~isempty(s)
                    S = [S;element_output_data(oi.EID,oi.elem_type,2,s)];
                end
                if ~isempty(e)
                    E = [E;element_output_data(oi.EID,oi.elem_type,3,e)];
                end
                if ~isempty(ese)
                    ESE = [ESE;element_output_data(oi.EID,oi.elem_type,4,ese)];
                end
            end
            SOLUTION.force = F;
            SOLUTION.stress = S;
            SOLUTION.strain = E;
            SOLUTION.strain_energy = ESE;
        end
        
    end
end

