clearvars; close all; clc
addpath(genpath(fullfile('..','..','cofe_toolbox')));


%%
file = 'cantileverBarFixedBoundaryReductionPartSuper';
filename=fullfile('gitControlTestDir',[file,'.f06']);
f06 = fileread(filename);
set = regexp(f06,'(?<name>[A-Z]+)[ ]+DISPLACEMENT SET','names');
setTable = regexp(f06,'0               -1-        -2-        -3-        -4-        -5-        -6-        -7-        -8-        -9-       -10-([^a-z_A-Z]+)','tokens');

if size(set,2)~=size(setTable,2)
    error('Array sizes should match')
end
nSets = size(set,2);
nSuper=sum(strcmp({set.name}','A'));


iSet = 1;
iSuper =0;
dofSet = [];
dofSets = cell(0);
while iSet <= nSets
    if strcmp(set(iSet).name,'A')
        if iSet > 1
            dofSets{iSuper}=dofSet;
            dofSet = [];
        end
        iSuper = iSuper + 1;
    end
    setRows = regexp(setTable{iSet}{1},'(?<id>\d+)-(?<c>\d+)','names');
    for d =1:size(setRows,2)
        c = castInputField('DOF','',setRows(d).c,'uint32',NaN,0);
        id = castInputField('ID','',setRows(d).id,'uint32',NaN,0);
        dofSet = [dofSet;...
            DofSet(lower(set(iSet).name),c,id)];
    end
    iSet = iSet + 1;
end
dofSets{iSuper}=dofSet;

% rearrange so residual structure is first
dofSets=dofSets([nSuper,1,2]);

%% Read in model from input file, creat duplicate, then overwrite DofSet - then preprocess and compare both model objects 
bdfLines  = BdfLines(fullfile('gitControlTestDir',[file,'.dat']));
bdfFields = BdfFields(bdfLines);
bdfEntries = BdfEntries(bdfFields);
modelCoFE = bdfEntries.entries2model();

%%
modelCoFE = modelCoFE.preprocess();
modelNas = modelCoFE;

for s = 1:nSuper
%     modelNas(s).nGdof = modelCoFE(s).nGdof;
%     modelNas(s) = modelNas(s).point.preprocess(modelNas(s));
    modelNas(s).dofSet = dofSets{s};
    modelNas(s) = modelNas(s).dofSet.fromNastranSets(modelNas(s));
%     modelNas(s) = DofSet.assemble(modelNas(s));
end

% [modelCoFE(1).a,modelNas(1).a]
% showTab = table([dofSets{1}.id]',[dofSets{1}.c]',{dofSets{1}.name}')
% table({set(1:18).name}',{set(1+(1:18)).name}',{set(36+(1:18)).name}')

%% ? create model function to write sets to table?
% [modelCoFE(1).a,modelNas(1).a]
s =1;

nPoints = size(modelCoFE(s).point,1);
point=[];
dof=[];
for p = 1:nPoints
    if modelCoFE(s).nodeFlag(p)
        point = [point;modelCoFE(s).point(p).id*ones(6,1,'uint32')];
        dof = [dof;(1:6)'];
    else
        point = [point;modelCoFE(s).point(p).id];
        dof = [dof;0];
    end
end

Sets = {'a','b','t','o','q'}; clc
% Sets = {'sb','sg','s'}; clc
% Sets = {'sb','sg','s','o','q','r','a','b','c','t','f'}; clc
% Sets = {'o'}; clc
for i = 1:size(Sets,2)
    printMat = [point,dof,modelCoFE(s).(Sets{i}),modelNas(s).(Sets{i})];
    fprintf(1,'\n--- %s SET ---\n',upper(Sets{i}))
    fprintf(1,'%8s-%s%2s%4s\n','Point','DOF','C','N')
    fprintf(1,'%8d-%d%4d%4d\n',printMat')
end


