function plot(obj,allDef,varargin)

% independent node
if isempty(allDef);
    def = zeros(3,1);
else
    def = allDef(obj.gdofn_plot);
end
pn = obj.xn + def;

% dependent nodes
nm = size(obj.xm,2);
if isempty(allDef);
    def = zeros(3,nm);
else
    def = allDef(obj.gdofm_plot);
end
pm = obj.xm + def;

% plot all
p = zeros(3,2*nm-1);
p(:,1:2:end) = pm;
p(:,2:2:end) = repmat(pn,[1,max([nm-1,1])]);
plot3(p(1,:),p(2,:),p(3,:),varargin{:})
