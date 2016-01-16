function obj = element(obj,FEM)

%% independent degrees of freedom (n set) 

% numbers and locations
hn = find(FEM.gnum==obj.GN);
if size(hn,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.GN),'']); end
obj.xn = [FEM.GRID(hn).X1;FEM.GRID(hn).X2;FEM.GRID(hn).X3];

% dof
cm = str2num(num2str(obj.CM)');
ldofn = cm';
obj.gdofn = FEM.gnum2gdof(cm,hn)';
num_cm = size(cm,1);

% plot indices
obj.gdofn_plot = FEM.gnum2gdof(1:3,hn)';

%% dependent degrees of freedom (m set) 

% number dependant nodes 
numDep = size(obj.GMi,2);
ldofg = 1:6*numDep;

% constraint equation matrix
RnRm = zeros(numDep*6,(1+numDep)*6);
RnRm(:,1:6) = repmat(eye(6),[numDep,1]);

% determine node numbers, locations, global DOF, and constraint equation matrix
obj.xm = zeros(3,numDep);
ldofm = zeros(1,num_cm*numDep);
obj.gdofm = zeros(1,num_cm*numDep);
obj.gdofm_plot = zeros(3,numDep);
for j = 1:numDep
    hmj = find(FEM.gnum == obj.GMi(j));
    if size(hmj,2)~=1; error(['There should be one and only one GRID with ID#',num2str(obj.(obj.fields{4+j})),'']); end
    obj.xm(:,j) = [FEM.GRID(hmj).X1;FEM.GRID(hmj).X2;FEM.GRID(hmj).X3];
    
    % dof
    ldofm((1:num_cm)+num_cm*(j-1)) = ldofg(cm + 6*(j-1));
    obj.gdofm((1:num_cm)+num_cm*(j-1)) = FEM.gnum2gdof(cm,hmj);
    
    % plot indices
    obj.gdofm_plot(:,j) = FEM.gnum2gdof(1:3,hmj);
    
    % constraint equation matrix
    D = obj.xm(:,j) - obj.xn;
    RnRm((1:6)+6*(j-1),(1:6)+6*j) = ...
     -1*[1     0     0     0    -D(3)  D(2) 
         0     1     0     D(3)  0    -D(1)
         0     0     1    -D(2)  D(1)  0
         0     0     0     1     0     0
         0     0     0     0     1     0
         0     0     0     0     0     1   ];

end

%% Element Constraint Matrix
obj.RnRm = RnRm(ldofm,[ldofn,6+ldofm]);

end