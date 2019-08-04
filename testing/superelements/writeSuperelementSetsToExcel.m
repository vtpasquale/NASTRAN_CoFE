clearvars; close all; clc
addpath(genpath(fullfile('..','..','nastran_cofe')));


%%
% fileName = 'cbSuper3Modes';
% filePath = fullfile('gitControlTestDir','cantilever_bar_scramble','part_super_cb');
% filePath = fullfile('gitControlTestDir','cantilever_bar','part_super_cb');

fileName = 'dynamicReduction';
filePath = fullfile('gitControlTestDir','cantilever_bar','no_super');

% fileName = 'guyanSuper';
% filePath = fullfile('gitControlTestDir','truss216','guyan_super');

%% Read dofSets from F06
dofSets = getSetsFromF06(fullfile(filePath,[lower(fileName),'.f06']));

%% Read in model from input file, creat duplicate, then overwrite DofSet - then preprocess and compare both model objects 
cofe = Cofe(fullfile(filePath,[fileName,'.dat']),'assemble',false);
modelCoFE = cofe.model;
modelNas = modelCoFE;

for s = 1:size(modelNas,1)
    modelNas(s).dofSet = dofSets{s};
    modelNas(s) = modelNas(s).dofSet.fromNastranSets(modelNas(s));
end

%%
compareSets = {'s','o','q','r','a','b','c','t','f'};
for super = 1:size(modelCoFE,1)
    for i = 1:size(compareSets,2)
        all(modelCoFE(super).(compareSets{i})==modelNas(super).(compareSets{i}))
    end
end

%% ? create model function to write sets to table?
% [modelCoFE(1).a,modelNas(1).a]

% Sets = {'a','b','t','o','q'}; clc
% Sets = {'sb','sg','s'}; clc
Sets = {'sb','sg','s','o','q','r','a','b','c','t','f'}; clc
% Sets = {'o'}; clc
delete('compareSets.xlsx')
for s = 1:size(modelCoFE,1)
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
    
    % print to command window
    % for i = 1:size(Sets,2)
    %     printMat = [point,dof,modelCoFE(s).(Sets{i}),modelNas(s).(Sets{i})];
    %     fprintf(1,'\n--- %s SET ---\n',upper(Sets{i}))
    %     fprintf(1,'%8s-%s%2s%4s\n','Point','DOF','C','N')
    %     fprintf(1,'%8d-%d%4d%4d\n',printMat')
    % end
    
    
    % Header
    nSets = size(Sets,2);
    xl = cell(modelCoFE(s).nGdof+2,3*nSets+2);
    xl(1,3:3:end)=Sets;
    xl(2,1)={'Point'};
    xl(2,2)={'DOF'};
    xl(2,3:3:end)={'CoFE'};
    xl(2,4:3:end)={'Nas'};
    
    % Data
    xl(3:end,1)=num2cell(point); % Point numbers
    xl(3:end,2)=num2cell(dof); % DOF numbers
    for i = 1:size(Sets,2)
        indexCoFE = find(modelCoFE(s).(Sets{i}));
        indexNas  = find(modelNas(s).(Sets{i}));
        if any(indexCoFE)
            xl(2+indexCoFE,(3*(i-1))+3) = num2cell(1);
        end
        if any(indexNas)
            xl(2+indexNas ,(3*(i-1))+4) = num2cell(1);
        end
    end
    
    % Write to
    xlswrite('compareSets.xlsx',xl,sprintf('Super=%d',modelCoFE(s).superElementID) )
end
