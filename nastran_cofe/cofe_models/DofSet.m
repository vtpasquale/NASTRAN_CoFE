% Model class to store input data that defines degree of freedom sets.
% The data are convereted to logical arrays after global degrees of
% freedom are defined.
% Anthony Ricciardi
%
classdef DofSet
    properties
        name % [1,1 char] Name of set (e.g., 'a','b','c','q','o')
        c % [:,1 uint32] Component numbers: zero or integers between 1 and 6.
        id % [:,1 uint32] point identification numbers.
    end
    methods
        function obj = DofSet(nameIn,cIn,idIn)
            % class constructor
            obj.name = nameIn;
            obj.c = cIn;
            obj.id = idIn;
        end
        function model = preprocess(obj,model)
            % function to create logical arrays from model sets
            % Logical arrays are true where set members are present in the
            % model g set.
            
            % cell of set names
            setNames = {obj.name}';
            
            % preallocate sets
            model.a = false(model.nGdof,1);
            model.b = false(model.nGdof,1);
            model.c = false(model.nGdof,1);
            model.q = false(model.nGdof,1);
            model.r = false(model.nGdof,1);
            model.o = false(model.nGdof,1);
            model.t = false(model.nGdof,1);
            
            % populate logical arrays
            model.a = add2LogicalSet(obj(strcmp(setNames,'a')),model.a,model);
            model.b = add2LogicalSet(obj(strcmp(setNames,'b')),model.b,model);
            model.c = add2LogicalSet(obj(strcmp(setNames,'c')),model.c,model);
            model.q = add2LogicalSet(obj(strcmp(setNames,'q')),model.q,model);
            model.r = add2LogicalSet(obj(strcmp(setNames,'r')),model.r,model);
            model.o = add2LogicalSet(obj(strcmp(setNames,'o')),model.o,model);
            
            % check input sets
            if any(model.a & model.o)
                error('A-set and O-set degrees-of-freedom should be exclusive. Check ASET, ASET1, OMIT, and OMIT1 inputs.')
            end
            if any(all([model.b,model.c,model.q,model.r,model.o],2))
                error('Mutually exclusive degree-of-freedom sets are not exclusive. Check *SETi, OMITi, and/or SUPORTi inputs.')
            end
        end % preprocess()
        function model = fromNastranSets(obj,model)
            % function to create logical arrays from model sets
            % Logical arrays are true where set members are present in the
            % model g set.
            
            % cell of set names
            setNames = {obj.name}';
            setLoop={'sb','sg','s','o','q','r','a','b','c','t','f'};
            for i = 1:size(setLoop,2)
                sl = setLoop{i};
                % preallocate sets
                model.(sl) = false(model.nGdof,1);
                
                % populate logical arrays
                model.(sl) = add2LogicalSet(obj(strcmp(setNames,sl)),model.(sl),model);
            end
        end % fromNastranSets()
    end
    methods (Static = true)
        function model = partition(model)
            % partition model logical array sets
            % This function doesn't actually operate on DofSet object data,
            % but on logical arrays created from DofSet data. This function
            % is kept in the DofSet class for organization only.
            [nModel,m]=size(model);
            if m~=1; error('Function only operates on Model arrays size n x 1.'); end
            
            se = model(1).superElement;
            nSuper = size(se,1);
            if nSuper > 0
                % Boundary connections defined using: SECONCT, SEIDA, SEIDB
                for i =1:nSuper
                    mI = se(i).modelIndex;
                    model(1 ).t(model(mI).seconctIndexInGSet0) = true;
                    model(mI).t(model(mI).seconctIndexInGSet ) = true;
                end
                
                % Remove QSET from TSET
                for i = 1:nModel
                    model(i).t(model(i).q)=false;
                end
                
                % S, SG, and SB SETs
                % Are preprocessed by point.getPerminantSinglePointConstraints(), and
                % spcs.preprocess(), model.preprocess()
                
                % SG SET
                % IF THE PERMANENT SET CONSTRAINT SPECIFICATION FOR BOUNDARY
                % GRIDS ARE IS DIFFERENT FROM THE UPSTREAM SUPERELEMENT THEN
                % THE PERMANENT SET CONSTRAINTS WILL BE UNIONED.
                for i = 1:nSuper
                    mI = se(i).modelIndex;
                    
                    % Add any connected upstream permanent constraints (SG) to
                    % the residual structure boundary constraints (SB) 
                    model(1).sg(model(mI).seconctIndexInGSet0) = model(1).sg(model(mI).seconctIndexInGSet0) | model(mI).sg(model(mI).seconctIndexInGSet);
                    
                    % Remove connected upstream permanent constraints
                    model(mI).sg(model(mI).seconctIndexInGSet) = false;
                    
                end
                % Remove permanent single point constraint DOF from free
                % residual structure sets
                model(1).t(model(1).sg)=false;
                model(1).a(model(1).sg)=false;
                model(1).b(model(1).sg)=false;
                model(1).c(model(1).sg)=false;
                model(1).q(model(1).sg)=false;
                model(1).r(model(1).sg)=false;
                % model(1).o(model(1).sg)=false;
                
                % Add superelement TSET to superelement BSET (not for residual structure)
                for i = 1:nSuper
                    mI = se(i).modelIndex;
                    model(mI).b(model(mI).t) = true;
                end
                
                % SB SET
                % If one of the PARTs is at a lower level in the tree, then you must apply
                % the desired constraints at the connection inside the PART that is lowest
                % in the processing tree (last of the group to be processed).
                % Remove connected upstream permanent constraints
                for i = 1:nSuper
                    mI = se(i).modelIndex;
                    model(mI).sb(model(mI).seconctIndexInGSet) = false;
                end
            end
            
            for i = 1:nModel
                model(i) = DofSet.partition_sub(model(i));
            end
            
%             % deal with aset connections - which may be different than seconct connections
%             if nModel > 1
%                 keyboard
%                 aSet0IndexInGSet0 = cumsum(model(1).a); 
%                 aSet0IndexInGSet0(~model(1).a)=0;
%                 for i = 2:nModel
%                     model(i).seconctIndexInGSet0 & model(1).a;
%                     
%                     model(i).seconctIndexInASet0 = seconct0IndexInGSet0(model(i).seconctIndexInGSet0);
%                     % remove DOFS that are not actually in ASET
%                     model(i).seconctIndexInASet0=model(i).seconctIndexInASet0(model(i).seconctIndexInASet0~=0);
%                 end
%             end
            
        end
        function model = partition_sub(model)
            % partition model logical array sets 

            % Constrained set
            model.s = model.sb | model.sg;
            
            % free structural degrees-of-freedom
            model.f = ~model.s & ~model.m;
            
            if model.superElementID ~=0
                % Superelement processing
                model.a = model.t | model.q;
                if any(model.o); warning('OMITi entries are ignored on superelements.'); end 
                model.o = model.f & ~model.a;
            else
                % Residual structure processing
                
                % The a-set and o-set are created in the following ways:
                %    1. If only OMITi entries are present, then the o-set consists
                %       of degrees-of-freedom listed explicitly on OMITi entries.
                %       The remaining f-set degrees-of-freedom are placed in the
                %       b-set, which is a subset of the a-set.
                if any(model.o) && ~any([model.a;model.b;model.c;model.q;model.r])
                    model.b = model.f & ~model.o;
                    model.a = model.b;
                    % 2. If ASETi or QSETi entries are present, then the a-set
                    %    consists of all degrees-of-freedom listed on ASETi entries
                    %    and any entries listing its subsets, such as QSETi, SUPORTi
                    %    CSETi, and BSETi entries. Any OMITi entries are redundant.
                    %    The remaining f-set degrees-of-freedom are placed in the
                    %    o-set.
                elseif any([model.a;model.q])
                    model.a = any([model.a,model.b,model.c,model.q,model.r],2);
                    if any(model.o) % check no overlap with O set
                        if any(model.a & model.o)
                            error('OMITi entries cannot overlap with ASETi entries or any ASET subsets, such as QSETi, SUPORTi, CSETi, and BSETi entries.')
                        end
                    end
                    model.o = model.f & ~model.a; % assign remaining to O set
                    % 3. If there are no ASETi, QSETi, or OMITi entries present but
                    %    there are SUPORTi, BSETi, or CSETi entries present, then
                    %    the entire f-set is placed in the a-set and the o-set is
                    %    not created.
                elseif (~any([model.a;model.q;model.o]) && any([model.b;model.c;model.r]) )
                    model.a = model.f;
                    % 4. There must be at least one explicit ASETi, QSETi, or OMITi
                    %    entry for the o-set to exist, even if the ASETi, QSETi, or
                    %    OMITi entry is redundant. (related to item 3)
                else
                    % No model reduction - same as previous option
                    model.a = model.f;
                end
                % Add ASET to residual structure TSET
                model.t = model.a & ~model.q;
            end
        end
    end
end

% If there are no CSETi or BSETi entries present, all a-set points are
% considered fixed during component mode analysis. If there are only BSETi
% entries present, any a-set degrees-of-freedom not listed are placed in
% the free boundary set (c-set). If there are both BSETi and CSETi entries
% present, the c-set degrees-of-freedom are defined by the CSETi entries,
% and any remaining a-set points are placed in the b-set.


function logicalSet = add2LogicalSet(dofSet,logicalSet,model)
% functions adds DofSet array to a logical array
nDofSet = size(dofSet,1);

% all DofSet objects in array
for i = 1:nDofSet
    dofSeti=dofSet(i);
    
    % all Points is dofset object
    for j = 1:size(dofSeti.id,2)
        point = model.point.getPoint(dofSeti.id(j),model);
        
        % handel nodes and scalar points
        if dofSeti.c(1)==0
            if isa(point,'ScalarPoint')
                logicalSet(point.gdof)=true;
            else
                error('There is a set that references Node %d component 0. Component 0 is only applicable for scalar points',point.id);
            end
        else
            if isa(point,'Node')
                logicalSet(point.gdof(dofSeti.c))=true;
            else
                error('A set definition refereces nonzero components or multiple components for scalar point %d. Only a single component, component 0, is applicable for scalar points.',point.id);
            end
        end
    end
end
end % add2LogicalSet()