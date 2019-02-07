% Abstract superclass for element properties
% Anthony Ricciardi
%
classdef (Abstract) Property < matlab.mixin.Heterogeneous

    properties (Abstract)
        pid % [int] Property identification number.
    end
    methods (Abstract)
        % accesses and saves material data to property objects - to save assembly time
        obj = setMaterial(obj,model)
    end
    methods (Sealed=true)
        function obj = preprocess(obj,model)
            % Function to preprocess properties
            
            % check that property id numbers are unique
            unsortedIds = [obj.pid];
            nProperty = size(obj,1);
            [~,ia] = unique(unsortedIds,'stable');
            if size(ia,1)~=nProperty
                nonunique=setxor(ia,1:nProperty);
                error('Property identification numbers should be unique. Nonunique property identification number(s): %s',sprintf('%d,',unsortedIds(nonunique)))
            end
            
            % Sort by PID
            [~,ias] = sort(unsortedIds);
            obj = obj(ias);
                   
            % access and save material data to property object - to save assembly time
            for i = 1:nProperty
                obj(i) = obj(i).setMaterial(model);
            end
            
        end
        function property = getProperty(obj,id,model,enforceTypeOption)
            % returns a single property object with the requested id from the property array
            index = (id == model.propertyPIDs);
            if ~any(index)
                error('Property PID = %d is referenced, but is undefined.',id);
            end
            property = obj(index);
            if size(property,1)~=1
                error('Property PID = %d is defined more than once.',id)
            end
            if nargin > 3
                if ~isa(property,enforceTypeOption)
                    error('Wrong property type referenced. Type should be %s.',enforceTypeOption)
                end
            end
        end % getProperty ()
    end
    
end

