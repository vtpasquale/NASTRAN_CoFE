clearvars; close all; clc
addpath(genpath(fullfile('..','..','..','nastran_cofe')));

%% Reference file
[out,optional] = Cofe(fullfile('reference_files','colinear_reference.dat'),...
                 'getBdfEntries',true,...
                 'stopAfterEntries',true);
bdfEntries = optional.bdfEntries;

%% RBE2 element fixed fields
bulkRbe2 = BulkEntryRbe2;
bulkRbe2.eid = uint32(1001);
bulkRbe2.gn  = uint32(3);
bulkRbe2.gm  = uint32([1,2,4,5]);

%% Batch script
bat = fopen(fullfile('test_cases','runNastran.bat'),'w+');

%% Test Cases
v = {'','1';'','2';'','3';'','4';'','5';'','6'};
for k1 = 1:2
for k2 = 1:2
for k3 = 1:2
for k4 = 1:2
for k5 = 1:2
for k6 = 1:2
str = [v{1,k1},v{2,k2},v{3,k3},v{4,k4},v{5,k5},v{6,k6}];
if ~isempty(str)
    cm = castInputField('RBE2','CM',str,'uint32',NaN,1,123456);
    cm = expandComponents(cm,'RBE2 CM',false);
    bulkRbe2.cm  = cm;
    
    fid = fopen(fullfile('test_cases',['colinear-',str,'.dat']),'w+');
    
    fprintf(fid,'SOL %s\n',bdfEntries.sol);
    fprintf(fid,'CEND\n');
    bdfEntries.caseEntry.echo(fid)
    fprintf(fid,'BEGIN BULK\n');
    fprintf(fid,'INCLUDE ''main_include.dat'' \n');
    bulkRbe2.echo(fid);
    fprintf(fid,'ENDDATA\n');
    
    fclose(fid);
    
    fprintf(bat,'call "C:\\MSC.Software\\MSC_Nastran\\20190\\bin\\nastran.exe" colinear-%s.dat old=no\n',str);
    
else
    %skip case with no contraints
end
end
end
end
end
end
end
fclose(bat);
        


