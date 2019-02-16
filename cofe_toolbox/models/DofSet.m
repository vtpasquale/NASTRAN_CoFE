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

             % populate logical arrays
             model.a = add2LogicalSet(obj(strcmp(setNames,'a')),model.a,model);
             model.b = add2LogicalSet(obj(strcmp(setNames,'b')),model.b,model);
             model.c = add2LogicalSet(obj(strcmp(setNames,'c')),model.c,model);
             model.q = add2LogicalSet(obj(strcmp(setNames,'q')),model.q,model);
             model.r = add2LogicalSet(obj(strcmp(setNames,'r')),model.r,model);
             model.o = add2LogicalSet(obj(strcmp(setNames,'o')),model.o,model);
             
             % check exclusive sets
             if any(model.a & model.o)
                 error('A-set and O-set degrees-of-freedom should be exclusive. Check ASET, ASET1, OMIT, and OMIT1 inputs.')
             end
             if any(sum([model.b,model.c,model.q,model.r,model.o],2)>1)
                 error('Mutually exclusive degree-of-freedom sets are not exclusive. Check xSETi, OMITi, and/or SUPORTi inputs.')
             end
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
        end % dofSet2Logical()
    end
    methods (Static = true)
        function model = assemble(model)
            % function assemble model logical array sets 
            % This function doesn't actually operate on DofSet object data, 
            % but on logical arrays created from DofSet data. This function
            % is kept in the DofSet class for organization only.

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
%             elseif (~any([obj.a;obj.q;obj.o]) && any([obj.b;obj.c;obj.r]) )
%                 obj.a = obj.f;
% 4. There must be at least one explicit ASETi, QSETi, or OMITi
%    entry for the o-set to exist, even if the ASETi, QSETi, or
%    OMITi entry is redundant. (related to item 3)
            else
                model.a = model.f;
            end
        end
    end
end
