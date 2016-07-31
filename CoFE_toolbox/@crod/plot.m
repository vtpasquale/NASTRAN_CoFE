function ph = plot(obj,allDef,varargin)

x = [obj.x1,obj.x2];

if isempty(allDef);
    def = zeros(3,2);
else
    def = allDef([obj.gdof(1:3),obj.gdof(7:9)]);
end

% points
p = x + def;
ph = plot3(p(1,:),p(2,:),p(3,:),varargin{1:end});