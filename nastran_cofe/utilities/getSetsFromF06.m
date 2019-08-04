function dofSets = getSetsFromF06(filename)
% Function to read degree-of-freedom sets from a Nastran F06 file
%
% To use, include the following in the Nastran input bulk data section: 
%    PARAM,USETPRT,12
%    PARAM,USETSEL,-1
%
% INPUT
% filename = [char] Nastran .f06 output file with set data
%
% OUTPUT
% dofSets = [n,1 DofSet] Object array that defines degree-of-freedom sets

% Anthony Ricciardi

f06 = fileread(filename);
set = regexp(f06,'(?<name>[A-Z]+)[ ]+DISPLACEMENT SET','names');
setTable = regexp(f06,'0               -1-        -2-        -3-        -4-        -5-        -6-        -7-        -8-        -9-       -10-([^a-z_A-Z]+)','tokens');

if size(set,2)~=size(setTable,2)
    error('Array sizes should match')
end
nSets = size(set,2);
% nSuper=sum(strcmp({set.name}','A'));

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
dofSets=dofSets([iSuper,1:iSuper-1]);