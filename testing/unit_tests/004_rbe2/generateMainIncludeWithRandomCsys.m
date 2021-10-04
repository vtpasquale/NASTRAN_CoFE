clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));

[out,optional] = Cofe(fullfile('reference_files','colinear_reference.dat'),...
                 'getBdfEntries',true,...
                 'stopAfterEntries',true);

bdfEntries = optional.bdfEntries;
% bdfEntries.echo(1)

%% Generate Random Coordinate Systems
bulkEntryCoord = generateRandomCoordinateSystems(20);
% bulkEntryCoord.echo(1)

%% Preprocess coordiante systems (need for updating node definitions)
coord = bulkEntryCoord.entry2model({bulkEntryCoord},0);
coordinateSystems = coord.coordinateSystem.preprocess();

%% Assign random definition and and output coordinate systems
cids = [coordinateSystems.cid].';
nCsys = size(cids,1);

% loop over nodes
for i = 1:7
    nodeEntry = bdfEntries.bulkEntry{1}(i);
    x_0 = [nodeEntry.x1;nodeEntry.x2;nodeEntry.x3];
    
    cpIndex = randi([2,nCsys],1);
    nodeEntry.cp = cids(cpIndex);
    x_c = coordinateSystems(cpIndex).x_c(x_0);
    nodeEntry.x1 = x_c(1);
    nodeEntry.x2 = x_c(2);
    nodeEntry.x3 = x_c(3);
    
    cdIndex = randi([2,nCsys],1);
    nodeEntry.cd = cids(cdIndex);
    
    bdfEntries.bulkEntry{1}(i) = nodeEntry;
end

%% Write Main Include File
bdfEntries.bulkEntry{1} = [bdfEntries.bulkEntry{1};bulkEntryCoord];
fid = fopen(fullfile('test_cases','main_include.dat'),'w+');
bdfEntries.bulkEntry{1}.echo(fid)
fclose(fid);