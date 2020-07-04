% Abstract superclass for elastic elements
% Anthony Ricciardi
%
classdef (Abstract) Element < matlab.mixin.Heterogeneous
    
    properties (Abstract)
        eid % [int] Element identification number.
        g % [1,: int] Node identification numbers of connection points.
        gdof % [ngdof,1 int] Indices of of element degrees of freedom in global set
        
        R_eg % [12 x 12 double] rotation matrix from the element reference frame to the nodal displacement reference frame
        k_e % [12 x 12 double] element stiffness matrix in the element reference frame
        m_e % [12 x 12 double] element mass matrix in the element reference frame
        
        volume % [double] element volume
        mass % [double] element mass
    end
%     properties (Abstract=true,Hidden=true)
%         ELEMENT_TYPE % [uint8] NASTRAN element code corresponding to NASTRAN item codes documentation
%         HDF5_ELEMENT_FORCE_CLASSNAME
% %         HDF5_STRESS_CLASSNAME
% %         HDF5_STRAIN_CLASSNAME
%     end
    methods (Abstract)
        obj = assemble_sub(obj,model) % Calculate element matricies
        obj = recover_sub(obj,u_g) % Recover element response values
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % preprocess elements
            [nelem,m] = size(obj);
            if m > 1; error('elem.preprocess() can only handel nx1 arrays of elem objects. The second dimension exceeds 1.'); end
            
            % check that element id numbers are unique
            EIDS=[obj.eid];
            
            [~,ia] = unique(EIDS,'stable');
            if size(ia,1)~=nelem
                nonunique=setxor(ia,1:nelem);
                error('Element identification numbers should be unique. Nonunique element identification number(s): %s',sprintf('%d,',EIDS(nonunique)))
            end
        end
        function model = assemble(obj,model)
            % assemble element and global matricies
            
            % Preallocate Sparse Matrices
            K_gg = spalloc(model.nGdof,model.nGdof,20*model.nGdof);
            M_gg = K_gg;
            
            % Loop through elements
            nElement = size(obj,1);
            for i=1:nElement
                oi=obj(i).assemble_sub(model);
                K_gg(oi.gdof,oi.gdof)=K_gg(oi.gdof,oi.gdof)+oi.R_eg.'*oi.k_e*oi.R_eg;
                M_gg(oi.gdof,oi.gdof)=M_gg(oi.gdof,oi.gdof)+oi.R_eg.'*oi.m_e*oi.R_eg;
                obj(i)=oi;
            end
            model.element=obj;
            model.K_gg=K_gg;
            model.M_gg=M_gg;
        end
        function solution = recover(obj,solution,model)
            % Function to recover element quantities from solution.
            % This method is called speratly for each superelement and
            % seperatly for each subcase.
            %
            % INPUTS
            % solution = [1,1 Solution] Solution object without recovered output data
            % model = [1,1 Model] 
            % 
            %
            % OUTPUT
            % solution = [1,1 Solution] Solution object with recovered output data
            
            % recovers element output data
            caseControl = model.caseControl(solution.caseControlIndex);
            
            nElement = size(obj,1);
            IDs = uint32([obj.eid]).';
            
            % returnIO [nElement,4] [force,stress,strain,strain_energy]
            returnFlags = false(nElement,4);
            returnFlags(...
                caseControl.force.getRequestMemberIndices(IDs,caseControl.outputSet),...
                1) = true;
            returnFlags(...
                caseControl.stress.getRequestMemberIndices(IDs,caseControl.outputSet),...
                2) = true;
            returnFlags(...
                caseControl.strain.getRequestMemberIndices(IDs,caseControl.outputSet),...
                3) = true;
            returnFlags(...
                caseControl.ese.getRequestMemberIndices(IDs,caseControl.outputSet),...
                4) = true;
            
            % Any element indices where element results are requested
            recoverIndex = uint32(find(any(returnFlags,2)));
            
            % preallocate element_output_data objects
            % s(nstress,1) = ElementOutputData();
            u_g = solution.u_g;
            F = [];
            S = [];
            E = [];
            ESE = [];
            for i = 1:size(recoverIndex,1)
                elementIndex = recoverIndex(i);
                oi = obj(elementIndex);
                [f,s,e,ese] = oi.recover_sub(u_g,model,returnFlags(elementIndex,:));
                if ~isempty(f)
                    F = [F;ElementOutputData(oi.eid,oi.ELEMENT_TYPE,1,f)];
                end
                if ~isempty(s)
                    S = [S;ElementOutputData(oi.eid,oi.ELEMENT_TYPE,2,s)];
                end
                if ~isempty(e)
                    E = [E;ElementOutputData(oi.eid,oi.ELEMENT_TYPE,3,e)];
                end
                if ~isempty(ese)
                    ESE = [ESE;ElementOutputData(oi.eid,oi.ELEMENT_TYPE,4,ese)];
                end
            end
            solution.force = F;
            solution.stress = S;
            solution.strain = E;
            solution.ese = ESE;
        end
    end
end

