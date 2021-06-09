% Abstract superclass for materials.
% Anthony Ricciardi
%
classdef (Abstract) Material < matlab.mixin.Heterogeneous

    properties (Abstract)
        mid % [uint32] Material identification number.
    end
    methods (Sealed=true)
        function obj = preprocess(obj)
            % Function to preprocess properties
            
            % check that material id numbers are unique
            unsortedIds=[obj.mid];
            nMaterials = size(obj,1);
            [~,ia] = unique(unsortedIds,'stable');
            if size(ia,1)~=nMaterials
                nonunique=setxor(ia,1:nMaterials);
                error('Material identification numbers should be unique. Nonunique material identification number(s): %s',sprintf('%d,',unsortedIds(nonunique)))
            end
            
            % Sort by MID
            [~,ias] = sort(unsortedIds);
            obj = obj(ias);
        end
        function material = getMaterial(obj,id,model,enforceTypeOption)
            % returns a single material object with the requested id from the material array
            index = (id == model.materialMIDs);
            if ~any(index)
                error('Material MID = %d is referenced, but is undefined.',id);
            end
            material = obj(index);
            if size(material,1)~=1
                error('Material MID = %d is defined more than once.',id)
            end
            if nargin > 3
                if ~isa(material,enforceTypeOption)
                    error('Wrong Material type referenced. Type should be %s.',enforceTypeOption)
                end
            end
        end % getMaterial ()
    end
end

