clear all; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));


nCsysSeed = 100;
nNodeSeed = 100;

% random id number
cids = int32(randi([1,10000],nCsysSeed,1));
cids = unique(cids,'stable');
nCsys=size(cids,1);

% random type
rcs = randi([1,3],nCsys,1); % rectangular, cylindrical, sphereical

% random ref cid
rid = int32(zeros(nCsys,1));
defined = int32(0);
undefined = cids;
undefinedIndex = 1:nCsys;
for i = 1:nCsys
    ind = randi([1,nCsys-i+1]);
    refIndex = randi([1,i]);
    
    rid(undefinedIndex(ind))=defined(refIndex);
    defined=[defined;cids(undefinedIndex(ind))];
    undefinedIndex=undefinedIndex((1:(nCsys-i+1))~=ind);
end

% create coordinate system entries
for i = 1:nCsys
    switch rcs(i)
        case 1
            bulkEntryCoord(i,1) = BulkEntryCord2r;
        case 2
            bulkEntryCoord(i,1) = BulkEntryCord2c;
        case 3
            bulkEntryCoord(i,1) = BulkEntryCord2s;
        otherwise
            error('wrong type')
    end
    if rid(i)==0
        refType=1;
    else
        refType = rcs(find(rid(i)==cids));
    end
    switch refType
        case 1
            a  = 100*(rand(3,1)-.5);
            b  = 100*(rand(3,1)-.5);
            c = 100*(rand(3,1)-.5);
        case 2
            mt =[100*(rand(1,3)-.5);
                 360*(rand(1,3)-.5);
                 100*(rand(1,3)-.5)];
             a=mt(:,1);
             b=mt(:,2);
             c=mt(:,3);
        case 3
            mt =[100*(rand(1,3)-.5);
                 360*(rand(1,3)-.5);
                 180* rand(1,3)];
             a=mt(:,1);
             b=mt(:,2);
             c=mt(:,3);
        otherwise
            error('wrong type')
    end
    bulkEntryCoord(i).cid=cids(i);
    bulkEntryCoord(i).rid=rid(i);
    bulkEntryCoord(i).a=a;
    bulkEntryCoord(i).b=b;
    bulkEntryCoord(i).c=c;
end


%% random nodes
nids = int32(randi([1,10000],nNodeSeed,1));
nids = unique(nids);
nNodes = size(nids,1);

for i = 1:nNodes
    bulkEntryGrid(i,1) = BulkEntryGrid;
    bulkEntryGrid(i).id = nids(i);
    refIndex = randi([1,nCsys],1);
    bulkEntryGrid(i).cp=cids(refIndex);
    bulkEntryGrid(i).cd=cids(randi([1,nCsys],1));
    refType = rcs(refIndex);
    switch refType
        case 1
            x_P  = 100*(rand(3,1)-.5);
        case 2
            x_P =[100*(rand(1,1)-.5);
                 360*(rand(1,1)-.5);
                 100*(rand(1,1)-.5)];
        case 3
            x_P =[100*(rand(1,1)-.5);
                 360*(rand(1,1)-.5);
                 180* rand(1,1)];
        otherwise
            error('wrong type')
    end
    bulkEntryGrid(i).x1=x_P(1);
    bulkEntryGrid(i).x2=x_P(2);
    bulkEntryGrid(i).x3=x_P(3);
end

%% 
bulkEntries = [bulkEntryCoord;bulkEntryGrid];
bulkEntries.echo(1)
