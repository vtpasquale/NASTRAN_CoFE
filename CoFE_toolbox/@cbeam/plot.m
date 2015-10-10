function plot(obj,gnum,gnum2gdof,allDef,varargin)

x = [obj.x1,obj.x2];

if isempty(gnum2gdof);
    def = zeros(3,2);
else
    def = allDef(gnum2gdof(1:3,[find(gnum==obj.GA),find(gnum==obj.GB)]));
end

% line
p = x + def;
plot3(p(1,:),p(2,:),p(3,:),varargin{:})
