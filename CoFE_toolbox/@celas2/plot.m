function plot(obj,allDef,varargin)

x = [obj.x1,obj.x2];

if isempty(allDef);
    def = zeros(3,2);
else
    def = allDef(obj.gdof_plot);
end

% line
p = x + def;
plot3(p(1,:),p(2,:),p(3,:),varargin{:})
