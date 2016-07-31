function [obj,obj_prime] = recover(obj,obj_prime)

%% Element Recovery
for j = 1:size(obj.structureList,2)
    placeholderObj = obj.(obj.structureList{j});
    for i = 1:size(placeholderObj,2)
        placeholderObj(i) = placeholderObj(i).recover(obj);
    end
    obj.(obj.structureList{j}) = placeholderObj;
end

%% Element Recovery Design Derivatives
if nargout > 1
    for dv = 1:ndv
        for j = 1:size(obj.structureList,2)
            placeholderObj = obj.(obj.structureList{j}); % placeholder speeds code up rather than direct indexing
            placeholderObjPrime = obj_prime(dv).(obj.structureList{j});
            for i = 1:size(placeholderObj,2)
                [~,placeholderObjPrime(i)] = ...
                    recover(placeholderObj(i),obj,placeholderObjPrime(i),obj_prime(dv));
            end
            obj_prime(dv).(obj.structureList{j}) = placeholderObjPrime;
        end
    end
end
