function [obj,obj_prime] = differential(obj,obj_prime)
obj.kd = obj.force * obj.kd_unit_p;
if nargin > 1
    obj_prime.kd = obj_prime.force*obj.kd_unit_p + obj.force*d(obj_prime.kd_unit_p);
end
end