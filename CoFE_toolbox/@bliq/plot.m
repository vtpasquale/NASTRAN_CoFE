function plot(obj,gnum,gnum2gdof,allDef,varargin)

x = [obj.x1,obj.x2,obj.x3,obj.x4,obj.x1];
if isempty(allDef);
    def = zeros(3,4);
else
    def = allDef(gnum2gdof(1:3,[find(gnum==obj.G1),find(gnum==obj.G2),find(gnum==obj.G3),find(gnum==obj.G4)]));
end

% perimeter
p = x + [def,def(:,1)];
plot3(p(1,:),p(2,:),p(3,:),varargin{:})

end