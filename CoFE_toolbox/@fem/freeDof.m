function obj = freeDof(obj)
f =zeros(obj.ndof-length(obj.s),1);
uiter = 0;
for i =1:obj.ndof
    if any(i==obj.s) ~= 1
        uiter=uiter+1;
        f(uiter,1) = i;
    end
end
obj.f = f;