function [obj,obj_prime] = differential(obj,obj_prime)
obj.kd = zeros(6);
if nargout > 1
    obj_prime.kd = zeros(6);
end
end