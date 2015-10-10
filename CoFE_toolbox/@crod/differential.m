function [obj,obj_prime] = differential(obj,obj_prime)
obj.kd = obj.force(7) * obj.kd_unit_p;
if nargin > 1
    obj_prime.kd = obj_prime.force(7)*obj.kd_unit_p + obj.force(7)*d(obj_prime.kd_unit_p);
end
end