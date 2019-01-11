
%% BdfFields.sol should store the first SOL entry describer
bdfLines  = BdfLines(fullfile('gitControlTestDir','tenbar-hdf5.dat'));
bdfFields = BdfFields(bdfLines);

assert(strcmp(bdfFields.sol,'FIRSTSOLENTRY'),...
    'BdfFields.sol should store the first SOL entry describer.')

%% Check executive and case control processing
fileName = fullfile('gitIgnoreTestDir1','testBdfFields.dat');
fid = fopen(fileName,'w+');

fprintf(fid,'EXEC ENTRY\n');
fprintf(fid,'SOL 101\n');
fprintf(fid,'SOL 102\n');
fprintf(fid,'SOL 103\n');
fprintf(fid,'cend\n');

for subcase = 1:10;
    for i = 1:20
        fprintf(fid,'ENTRY%d (left hand describers %d)=right hand describers %d\n',i,i,i);
        fprintf(fid,'ENTRY%d =right hand describers %d\n',i,i);
    end
    fprintf(fid,' SUBCASE %d\n',subcase);
end
fprintf(fid,'begin bulk\n');
fprintf(fid,'enddata\n');
fclose(fid);

bdfLines  = BdfLines(fileName);
bdfFields = BdfFields(bdfLines);
iter = 0;
for subcase = 1:10;
    for i = 1:20
        iter = iter + 1;
        assert(strcmp(bdfFields.caseControl{iter}.entryName,sprintf('ENTRY%d',i)));
        assert(strcmp(bdfFields.caseControl{iter}.leftHandDescribers,sprintf('left hand describers %d',i)));
        assert(strcmp(bdfFields.caseControl{iter}.rightHandDescribers,sprintf('right hand describers %d',i)));
        iter = iter + 1;
        assert(strcmp(bdfFields.caseControl{iter}.entryName,sprintf('ENTRY%d',i)));
        assert(isempty(bdfFields.caseControl{iter}.leftHandDescribers));
        assert(strcmp(bdfFields.caseControl{iter}.rightHandDescribers,sprintf('right hand describers %d',i)));
    end
    iter = iter + 1;
    assert(strcmp(bdfFields.caseControl{iter}.entryName,sprintf('SUBCASE')));
    assert(strcmp(bdfFields.caseControl{iter}.rightHandDescribers,sprintf('%d',subcase)));
end

%
% fileName = fullfile('sourceControlledTestInputs','caseControlTestTenBar-000.dat');
% bdfLines  = BdfLines(fileName);
% bdfFields = BdfFields(bdfLines);
