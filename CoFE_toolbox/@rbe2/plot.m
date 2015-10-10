function plot(obj,gnum,gnum2gdof,allDef,varargin)

% independent node
if isempty(gnum2gdof);
    def = zeros(3,1);
else
    def = allDef(gnum2gdof(1:3,find(gnum==obj.GN)));
end
pn = obj.xn + def;

% dependent nodes
nm = size(obj.xm,2);
pm = zeros(3,nm);
for i = 1:nm;
    
    if isempty(gnum2gdof);
        def = zeros(3,1);
    else
        def = allDef(gnum2gdof(1:3,find(gnum==obj.GMi(i) )));
    end
    pm(:,i) = obj.xm(:,i) + def;
end

% plot all
p = zeros(3,2*nm-1);
p(:,1:2:end) = pm;
p(:,2:2:end) = repmat(pn,[1,max([nm-1,1])]);
plot3(p(1,:),p(2,:),p(3,:),varargin{:})
