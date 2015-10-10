function plot(obj,gnum,gnum2gdof,allDef,varargin)

% dependent node
if isempty(gnum2gdof);
    def = zeros(3,1);
else
    def = allDef(gnum2gdof(1:3,find(gnum==obj.REFGRID)));
end
pm = obj.xm + def;

% independent nodes
nn = size(obj.xn,2);
pn = zeros(3,nn);
for i = 1:nn;
    
    if isempty(gnum2gdof);
        def = zeros(3,1);
    else
        def = allDef(gnum2gdof(1:3,find(gnum==obj.G1i(i) )));
    end
    pn(:,i) = obj.xn(:,i) + def;
end

% plot all
p = zeros(3,2*nn-1);
p(:,1:2:end) = pn;
p(:,2:2:end) = repmat(pm,[1,max([nn-1,1])]);
plot3(p(1,:),p(2,:),p(3,:),varargin{:})
