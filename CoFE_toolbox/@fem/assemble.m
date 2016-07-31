function objNew = assemble(obj,CASE)

%% Node and DOF data
obj.nnodes = size(obj.GRID,2);
obj.ndof = 6.*obj.nnodes;
obj.gnum = [obj.GRID.ID]; % order of grid numbers
obj.gnum2gdof = zeros(6,obj.nnodes);
obj.gnum2gdof(1:obj.ndof) = 1:obj.ndof; % global degrees of freedom by grid number (each column corresponds to each row of gnum)
obj.gcoord = [[obj.GRID.X1].',[obj.GRID.X2].',[obj.GRID.X3].']';

%% Convert node positions to basic coordinate system
obj = obj.rot2c0();

%% Calculate PBEAM value for PBEAML entries
for j = 1:size(obj.PBEAML,2)
    obj.PBEAML(j) = makePBEAM(obj.PBEAML(j));
end

%% Calculate element matricies
% Loop through element types and elements
for j = 1:size(obj.elementList,2)
    placeholderObj = obj.(obj.elementList{j}); % placeholder speeds code up rather than direct indexing
    for i = 1:size(placeholderObj,2)
        placeholderObj(i) = placeholderObj(i).element(obj);
    end
    obj.(obj.elementList{j}) = placeholderObj;
    clear placeholderObj
end

for j = 1:size(obj.constraintList,2)
    for i = 1:size(obj.(obj.constraintList{j}),2)
        obj.(obj.constraintList{j})(i) = obj.(obj.constraintList{j})(i).element(obj);
    end
end

%% Single Point Constraints, Free DOF
obj = obj.spcDof(); % obj.s
obj = obj.freeDof(); % obj.f

%% Preallocate Sparse Matricies
obj.K_G = spalloc(obj.ndof,obj.ndof,20*obj.ndof);
obj.M_G = spalloc(obj.ndof,obj.ndof,20*obj.ndof);

%% Assemble Global Matricies
% Loop through element types
for j = 1:size(obj.structureList,2)
    for i = 1:size(obj.(obj.structureList{j}),2)
        gdof = obj.(obj.structureList{j})(i).gdof;
        obj.K_G(gdof,gdof)=obj.K_G(gdof,gdof)+obj.(obj.structureList{j})(i).ke;
        obj.M_G(gdof,gdof)=obj.M_G(gdof,gdof)+obj.(obj.structureList{j})(i).me;
    end
end

%% Loop through contraint types to determine dependent degrees of freedom (m set)
m = [];
for j = 1:size(obj.constraintList,2)   
    gdofm_type = [obj.(obj.constraintList{j}).gdofm];
    m = [m;gdofm_type(:)];
end
assert(size(unique(m),1) == size(m,1),'There is an issue with your m set.  m set DOF should be unique.')
obj.m = m;

%% determine independent degrees of freedom (n set)
if isempty(obj.m)
    n = (1:obj.ndof).';
else
    allDof = 1:obj.ndof;
    n = allDof(~sum(repmat(1:obj.ndof,[size(m,1),1]) == repmat(m,[1,obj.ndof]))).';
end
assert(size(unique(n),1) == size(n,1),'There is an issue with your n set.  n set DOF should be unique.')
obj.n = n;

% assemble constraint matrix
if isempty(obj.m)
    obj.Gm = [];
else
    RnRm = spalloc(obj.ndof,obj.ndof,72*size(m,1));
    for j = 1:size(obj.constraintList,2)
        for i = 1:size(obj.(obj.constraintList{j}),2)
            gdofn = obj.(obj.constraintList{j})(i).gdofn;
            gdofm = obj.(obj.constraintList{j})(i).gdofm;
            RnRm(gdofm,[gdofn,gdofm]) = obj.(obj.constraintList{j})(i).RnRm;
        end
    end
    obj.Gm = -RnRm(m,m)\RnRm(m,n);
end

%% Partitioning
if size(m,1) ~= 0
    % Check overlap of SPC and MPC
    for i = 1:size(obj.s,1)
        if any(obj.s(i)==m)
            error('You may not SPC a dependent dof')
        end
    end
      % Too much memory for large problems
%     if sum(sum( repmat(obj.s,[1,size(m,1)]) == repmat(m',[size(obj.s,1),1]) ))
%         error('You may not SPC a dependent dof')
%     end
end

% find independent unconstrained dof
% nfBoolean = sum(repmat(n,[1,size(obj.f,1)]) == repmat(obj.f.',[size(n,1),1]) , 2); Uses too much memory for large problems
nfBoolean(size(n,1)) = false;
for i = 1:size(n,1)
    if any(n(i)==obj.f)
        nfBoolean(i) = true;
    end
end 
    
% actual free and independant in g-set
nf_g = n(nfBoolean==true);

% index of free and independent dof in n-set
nf_n = 1:size(nfBoolean,2) ;
nf_n = nf_n(nfBoolean==true);
obj.nf_g = nf_g;
obj.nf_n = nf_n.';

%% Loads
if any([CASE.SOL]~=103)
    [lc,p] = loads(obj);
else
    % skip loads
end

%% Loop through SUBCASES
warning('off','MATLAB:structOnObject');
nSubCases = size(CASE,2);
for sc = 1:nSubCases
    objNew(sc) = obj;
    objNew(sc).CASE=struct(CASE(sc)); % convert to structure for execution speed
    % assign load case
    if CASE(sc).SOL ~= 103
        lind = find(lc==CASE(sc).LOAD);
        if isempty(lind)
            objNew(sc).p=zeros(obj.ndof,1);
        else
            objNew(sc).p=p(:,lind);
        end
    end
end