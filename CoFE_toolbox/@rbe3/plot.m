function plot(obj,allDef,varargin)

% dependent node
if isempty(allDef);
    def = zeros(3,1);
else
    def = allDef(obj.gdofm_plot);
end
pm = obj.xm + def;

% independent nodes
nn = size(obj.xn,2);
if isempty(allDef);
    def = zeros(3,nn);
else
    def = allDef(obj.gdofn_plot);
end
pn= obj.xn + def;


% plot all
p = zeros(3,2*nn-1);
p(:,1:2:end) = pn;
p(:,2:2:end) = repmat(pm,[1,max([nn-1,1])]);
plot3(p(1,:),p(2,:),p(3,:),varargin{:})
