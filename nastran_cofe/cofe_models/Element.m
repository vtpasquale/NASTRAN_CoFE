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
%         ELEMENT_TYPE % [uint8] Nastran element code corresponding to Nastran item codes documentation
%         HDF5_ELEMENT_FORCE_CLASSNAME
%         HDF5_STRAIN_CLASSNAME
%         HDF5_STRESS_CLASSNAME
%     end
    methods (Abstract)
        obj = assemble_sub(obj,model) % Calculate element matricies
        [force,stress,strain,strainEnergy,kineticEnergy] = recover_sub(obj,u_g,model,returnFlags) % Recover element response values
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
        function [gdof,p_g]=processPressureLoad(obj,pload)
            if size(obj,1)~=1
                error('processPressureLoad() is set up to process a single element object.')
            end
            [gdof,p_g]=obj.processPressureLoad_sub(pload);
        end
        function model = assemble(obj,model)
            % assemble element and global matricies
            
% %             % Inefficent assembly
% %             K_gg = spalloc(model.nGdof,model.nGdof,20*model.nGdof);
% %             M_gg = K_gg;
% %             
% %             % Loop through elements
% %             nElement = size(obj,1);
% %             for i=1:nElement
% %                 oi=obj(i).assemble_sub(model);
% %                 K_gg(oi.gdof,oi.gdof)=K_gg(oi.gdof,oi.gdof)+oi.R_eg.'*oi.k_e*oi.R_eg;
% %                 M_gg(oi.gdof,oi.gdof)=M_gg(oi.gdof,oi.gdof)+oi.R_eg.'*oi.m_e*oi.R_eg;
% %                 obj(i)=oi;
% %             end
% %             model.element=obj;
% %             model.K_gg=K_gg;
% %             model.M_gg=model.wtmass*M_gg;
            
%             K_gg1 = K_gg;
%             M_gg1 = M_gg;
            
% %             % Assembly using triplet functions
% %             [iK,jK,sK,nK] = initializeTriplet(20*model.nGdof);
% %             [iM,jM,sM,nM] = initializeTriplet( 5*model.nGdof);
% %             
% %             % Loop through elements
% %             nElement = size(obj,1);
% %             for i=1:nElement
% %                 oi=obj(i).assemble_sub(model);
% %                 kg = oi.R_eg.'*oi.k_e*oi.R_eg;
% %                 mg = oi.R_eg.'*oi.m_e*oi.R_eg;
% %                 gDof = oi.gdof;
% %                 [iK,jK,sK,nK] = updateTriplet(iK,jK,sK,nK,kg,gDof);
% %                 [iM,jM,sM,nM] = updateTriplet(iM,jM,sM,nM,mg,gDof);
% %                 obj(i)=oi;
% %             end
% %             model.element=obj;
% %             model.K_gg=sparse(double(iK(1:nK)),double(jK(1:nK)),sK(1:nK),...
% %                               model.nGdof,model.nGdof);
% %             model.M_gg=model.wtmass*...
% %                        sparse(double(iM(1:nM)),double(jM(1:nM)),sM(1:nM),...
% %                               model.nGdof,model.nGdof);

            % Assembly using triplet handle classes (value class performance is abysmal)
            K_gg = SparseTriplet(20*model.nGdof);
            M_gg = SparseTriplet( 5*model.nGdof);
            
            % Loop through elements
            nElement = size(obj,1);
            for i=1:nElement
                oi=obj(i).assemble_sub(model);
                kg = oi.R_eg.'*oi.k_e*oi.R_eg;
                mg = oi.R_eg.'*oi.m_e*oi.R_eg;
                gDof = oi.gdof;
                K_gg = K_gg.addMatrix(kg,gDof);
                M_gg = M_gg.addMatrix(mg,gDof);
                obj(i)=oi;
            end
            model.element=obj;
            model.K_gg=K_gg.convertToSparseMatrix(model.nGdof,model.nGdof);
            model.M_gg=model.wtmass*M_gg.convertToSparseMatrix(model.nGdof,model.nGdof);
            
        end
        function element = getElement(obj,id,model)
            % returns a single element object with the requested id from the element array
            index = (id == model.elementEIDs);
            if ~any(index)
                error('Element ID = %d is referenced, but is undefined.',id);
            end
            element = obj(index);
            if size(element,1)~=1
                error('Element ID = %d is defined more than once.',id)
            end
        end % getPoint()
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
            
            % returnFlags [nElement,5] [force,stress,strain,strain_energy,kinetic_energy]
            returnFlags = false(nElement,5);
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
            returnFlags(...
                caseControl.eke.getRequestMemberIndices(IDs,caseControl.outputSet),...
                5) = true;
            
            % Any element indices where element results are requested
            recoverIndex = uint32(find(any(returnFlags,2)));
            
            % Create empty ElementOutputData objects
            F = ElementOutputData.empty(0,1);
            S = ElementOutputData.empty(0,1);
            E = ElementOutputData.empty(0,1);
            ESE = ElementOutputData.empty(0,1);
            EKE = ElementOutputData.empty(0,1);
            % preallocation performace is similar
            %             nReturn=sum(returnFlags);
            %             F(nReturn(1),1) = ElementOutputData;
            %             S(nReturn(2),1) = ElementOutputData;
            %             E(nReturn(3),1) = ElementOutputData;
            %             ESE(nReturn(4),1) = ElementOutputData;
            %             EKE(nReturn(5),1) = ElementOutputData;
            %             iF = 0; iS = 0; iE = 0;
            
            % Type Codes
            forceCode = uint8(1);
            stressCode = uint8(2);
            strainCode = uint8(3);
            eseCode = uint8(4);
            ekeCode = uint8(5);
            
            % Recover Element Data
            u_g = solution.u_g;
            for i = 1:size(recoverIndex,1)
                elementIndex = recoverIndex(i);
                oi = obj(elementIndex);
                [f,s,e,ese,eke] = oi.recover_sub(u_g,model,returnFlags(elementIndex,:));
                if ~isempty(f)
                    F(end+1,1)=ElementOutputData(oi.eid,oi.ELEMENT_TYPE,forceCode,f);
                end
                if ~isempty(s)
                    S(end+1,1)=ElementOutputData(oi.eid,oi.ELEMENT_TYPE,stressCode,s);
                end
                if ~isempty(e)
                    E(end+1,1)=ElementOutputData(oi.eid,oi.ELEMENT_TYPE,strainCode,e);
                end
                if ~isempty(ese)
                    ese(2,:) = 100*ese(2,:)./solution.totalEnergy.';
                    ESE(end+1,1)=ElementOutputData(oi.eid,oi.ELEMENT_TYPE,eseCode,ese);
                end
                if ~isempty(eke)
                    if isa(solution,'ModesSolution')
                        eke = repmat(solution.w2.',[3,1]).*eke;
                        eke(2,:) = 100*eke(2,:)./solution.totalEnergy.';
                        EKE(end+1,1)=ElementOutputData(oi.eid,oi.ELEMENT_TYPE,ekeCode,eke);
                    end
                end
            end
            solution.force = F;
            solution.stress = S;
            solution.strain = E;
            solution.ese = ESE;
            solution.eke = EKE;
        end
    end
end

