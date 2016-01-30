function plot(obj,allDef,varargin)

x = [obj.x1,obj.x2,obj.x3,obj.x4];
if isempty(allDef);
    def = zeros(3,4);
else
    def = allDef([obj.gdof(1:3),obj.gdof(4:6),obj.gdof(7:9),obj.gdof(10:12)]);
end
p = x + def;

surf([p(1,1:2);p(1,4:-1:3)],[p(2,1:2);p(2,4:-1:3)],[p(3,1:2);p(3,4:-1:3)],'facecolor','none','edgecolor',varargin{2:end})
% surf([p(1,1:2);p(1,4:-1:3)],[p(2,1:2);p(2,4:-1:3)],[p(3,1:2);p(3,4:-1:3)],obj.stress(1,5)*ones(2,2),'facecolor','interp','edgecolor',varargin{2:end})


end