% Class for pressure loads on element faces
% Anthony Ricciardi
%
classdef Pload4 < Load
    
    properties
        sid % [uint32] Load set identification number.
        eid % [uint32] Element identification number.
        p % [4,1 double] Face pressure load at element corners.
        
        gdof % [1,n uint32] index of global degrees of freedom 
        p_g % [n,1 double] Force vector expressed in the nodal displacement coordinate system defined at global degrees of freedom.
    end
    methods
        function obj=preprocess_sub(obj,model)
            felement = model.element.getElement(obj.eid,model);
            if ~ismethod(felement, 'processPressureLoad_sub')
                metaClass = metaclass(felement);
                error('Element EID =  %d is element type %s. PLOAD4 is not implented for elements of this type.\n',felement.eid,upper(metaClass.Name) )
            end
            [obj.gdof,obj.p_g]=felement.processPressureLoad_sub(obj);
        end
    end
end
