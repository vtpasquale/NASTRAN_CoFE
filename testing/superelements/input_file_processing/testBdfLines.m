
% make test file directories if they don't exist
testDir1 = 'gitIgnoreTestDir1';
testDir2 = fullfile(testDir1,'gitIgnoreTestDir2');
testDir3 = fullfile(testDir2,'gitIgnoreTestDir3');
if exist(testDir1,'dir')==0
    mkdir(testDir1)
    mkdir(testDir2)
    mkdir(testDir3)
end

%% comment lines must be removed
test_file = 'remove_comment_lines.dat';
exec = {...
    'ID CODE'
    'SOL 101'
    '$ comment line'
    '  $ comment line'
    };
casec = {...
    'METHOD = 2'
    'DISP = 5'
    '$ comment line'
    '  $ comment line'
    'ECHO = NONE'
    };
bulk = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    '$ comment line'
    '  $ comment line'
    'CONM2,7059,5050,19,0.830505,,,,,'
    'SPC1,1,123456,2021,,,,,,'
    };

% write test input file
fid = fopen(fullfile(testDir1,test_file),'w+');
fprintf(fid,'%s\n',exec{:});
fprintf(fid,'CEND\n');
fprintf(fid,'%s\n',casec{:});
fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'%s\n',bulk{:});
fprintf(fid,'ENDDATA');
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(fullfile(testDir1,test_file));

% check results
assert(all(strcmp(bdfLines.executiveControl,exec(1:2))))
assert(all(strcmp(bdfLines.caseControl,casec([1:2,5]))))
assert(all(strcmp(bdfLines.bulkData{1},bulk([1:3,6:7]))))


%% trailing comments must be removed
% and leading and trailing whitespace are kept
test_file = 'remove_trailing_comments.dat';
exec = {...
    ' ID CODE'
    'SOL 101 $ trailing comment'
    };
exec_check = {...
    ' ID CODE'
    'SOL 101 '
    };

casec = {...
    ' METHOD = 2'
    'DISP = 5 $ $ trailing comment'
    'ECHO = NONE '
    };
casec_check = {...
    ' METHOD = 2'
    'DISP = 5 '
    'ECHO = NONE '
    };
bulk = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    'CONM2,7059,5050,19,0.830505,,,,,$ trailing comment'
    '  SPC1,1,123456,2021,,,,,,'
    };
bulk_check = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    'CONM2,7059,5050,19,0.830505,,,,,'
    '  SPC1,1,123456,2021,,,,,,'
    };
% write test input file
fid = fopen(fullfile(testDir1,test_file),'w+');
fprintf(fid,'%s\n',exec{:});
fprintf(fid,'CEND\n');
fprintf(fid,'%s\n',casec{:});
fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'%s\n',bulk{:});
fprintf(fid,'ENDDATA');
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(fullfile(testDir1,test_file));

% check results
assert(all(strcmp(bdfLines.executiveControl,exec_check)))
assert(all(strcmp(bdfLines.caseControl,casec_check)))
assert(all(strcmp(bdfLines.bulkData{1},bulk_check)))

%% stop at the first ENDDATA statement in bulk data section
test_file = 'stop_at_enddata.dat';
exec = {...
    'SOL 101'
    };
casec = {...
    'METHOD = 2'
    'DISP = ALL'
    };
bulk = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    'ENDDATA'
    'CONM2,7059,5050,19,0.830505,,,,,'
    'SPC1,1,123456,2021,,,,,,'
    };

% write test input file
fid = fopen(fullfile(testDir1,test_file),'w+');
fprintf(fid,'%s\n',exec{:});
fprintf(fid,'CEND\n');
fprintf(fid,'%s\n',casec{:});
fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'%s\n',bulk{:});
fprintf(fid,'ENDDATA');
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(fullfile(testDir1,test_file));

% check results
assert(all(strcmp(bdfLines.bulkData{1},bulk(1:3))))

%% handle nested INCLUDE statements
main1 = fullfile(testDir1,'main1.dat');

% write main file
fid = fopen(main1,'w+');
fprintf(fid,'INCLUDE ''exec1.dat''\n');
fprintf(fid,'INCLUDE ''casec1.dat''\n');
fprintf(fid,'INCLUDE ''bulk1.dat''\n');
fprintf(fid,'ENDDATA\n');
fclose(fid);

% write referenced files
names = {'exec';'casec';'bulk'};

start_dir = pwd;
for j = 1:2
    for i = 1:3
        fid = fopen(fullfile(sprintf('gitIgnoreTestDir%d',j),sprintf('%s%d.dat',names{i},j)),'w+');
        switch  j
            case 1
                fprintf(fid,'Dummy text 1\n');
                fprintf(fid,'Dummy text 2\n');
            case 2
                fprintf(fid,'Dummy text 3\n');
                fprintf(fid,'Dummy text 4\n');
            otherwise
                error('Add lines')
        end
        fprintf(fid,'INCLUDE ''%s''\n',fullfile(sprintf('gitIgnoreTestDir%d',j+1),sprintf('%s%d.dat',names{i},j+1)));
        fclose(fid);
    end
    cd(sprintf('gitIgnoreTestDir%d',j))
end
j = 3;
i = 1;
fid = fopen(fullfile(sprintf('gitIgnoreTestDir%d',j),sprintf('%s%d.dat',names{i},j)),'w+');
fprintf(fid,'Dummy text 5\n');
fprintf(fid,'Dummy text 6\n');
fprintf(fid,'INCLUDE ''%s''\n',fullfile('..','..','exec4.dat'));
fprintf(fid,'CEND\n');
fclose(fid);
i = 2;
fid = fopen(fullfile(sprintf('gitIgnoreTestDir%d',j),sprintf('%s%d.dat',names{i},j)),'w+');
fprintf(fid,'Dummy text 5\n');
fprintf(fid,'Dummy text 6\n');
fprintf(fid,'INCLUDE ''%s''\n',fullfile('..','..','casec4.dat'));
fprintf(fid,'BEGIN BULK\n');
fclose(fid);
i = 3;
fid = fopen(fullfile(sprintf('gitIgnoreTestDir%d',j),sprintf('%s%d.dat',names{i},j)),'w+');
fprintf(fid,'Dummy text 5\n');
fprintf(fid,'Dummy text 6\n');
fprintf(fid,'INCLUDE ''%s''\n',fullfile('..','..','bulk4.dat'));
fclose(fid);
cd(start_dir)
% downward reference files
j = 4;
for i = 1:3
    fid = fopen(fullfile('gitIgnoreTestDir1',sprintf('%s%d.dat',names{i},j)),'w+');
    fprintf(fid,'Dummy text 7\n');
    fprintf(fid,'Dummy text 8\n');
    fclose(fid);
end

% read the data using BdfLines.m
bdfLines = BdfLines(main1);

% check results
for i = 1:8
    check{i,1} = sprintf('Dummy text %d',i);
end
assert(all(strcmp(bdfLines.executiveControl,check)))
assert(all(strcmp(bdfLines.caseControl,check)))
assert(all(strcmp(bdfLines.bulkData{1},check)))

%% handle multiline include statements
% uses INCLUDE files generated for previous test case
test_file = 'gitIgnoreHandleMultilineInclude.dat';

% write main file
fid = fopen(test_file,'w+');
fprintf(fid,'INCLUDE ''gitIgnoreTestDir1%s\n',filesep);
fprintf(fid,'    gitIgnoreTestDir2%s\n',filesep);
fprintf(fid,'      gitIgnoreTestDir3%sexec3.dat''\n',filesep);
fprintf(fid,'INCLUDE ''gitIgnoreTestDir1%sgitIgnoreTestDir2%s\n',filesep,filesep);
fprintf(fid,'      gitIgnoreTestDir3%scasec3.dat''\n',filesep);
fprintf(fid,'INCLUDE ''%s''\n',fullfile(testDir3,'bulk3.dat'));
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(test_file);

% check results
clear check
for i = 1:4
    check{i,1} = sprintf('Dummy text %d',i+4);
end
assert(all(strcmp(bdfLines.executiveControl,check)))
assert(all(strcmp(bdfLines.caseControl,check)))
assert(all(strcmp(bdfLines.bulkData{1},check)))

%% warn if file ends before CEND
test_file = 'warn_end_before_cend.dat';
exec = {...
    'SOL 101'
    };
casec = {...
    'METHOD = 2'
    'DISP = ALL'
    };
bulk = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    'ENDDATA'
    'CONM2,7059,5050,19,0.830505,,,,,'
    'SPC1,1,123456,2021,,,,,,'
    };

% write test input file
fid = fopen(fullfile(testDir1,test_file),'w+');
fprintf(fid,'%s\n',exec{:});
% fprintf(fid,'CEND\n');
fprintf(fid,'%s\n',casec{:});
fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'%s\n',bulk{:});
fprintf(fid,'ENDDATA');
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(fullfile(testDir1,test_file));

% check the last warning
lastmsg = lastwarn();
assert(strcmp(lastmsg,'The input file ended before the CEND statement.'))

%% warn if file ends before BEGIN BULK
test_file = 'warn_end_before_bb.dat';
exec = {...
    'SOL 101'
    };
casec = {...
    'METHOD = 2'
    'DISP = ALL'
    };
bulk = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    'ENDDATA'
    'CONM2,7059,5050,19,0.830505,,,,,'
    'SPC1,1,123456,2021,,,,,,'
    };

% write test input file
fid = fopen(fullfile(testDir1,test_file),'w+');
fprintf(fid,'%s\n',exec{:});
fprintf(fid,'CEND\n');
fprintf(fid,'%s\n',casec{:});
% fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'%s\n',bulk{:});
fprintf(fid,'ENDDATA');
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(fullfile(testDir1,test_file));

% check the last warning
lastmsg = lastwarn();
assert(strcmp(lastmsg,'The input file ended before the BEGIN BULK statement.'))

%% warn if file ends before ENDDATA
test_file = 'warn_end_before_enddata.dat';
exec = {...
    'SOL 101'
    };
casec = {...
    'METHOD = 2'
    'DISP = ALL'
    };
bulk = {...
    'FORCE,88,5050,,1.000000,0.348006,0.226069,0.591637'
    'GRAV,9,0,80.500000,0.162368,0.000000,-0.986730'
    'LOAD    1025    1.0     1.0     88      1.0     9'
    'CONM2,7059,5050,19,0.830505,,,,,'
    'SPC1,1,123456,2021,,,,,,'
    };

% write test input file
fid = fopen(fullfile(testDir1,test_file),'w+');
fprintf(fid,'%s\n',exec{:});
fprintf(fid,'CEND\n');
fprintf(fid,'%s\n',casec{:});
fprintf(fid,'BEGIN BULK\n');
fprintf(fid,'%s\n',bulk{:});
% fprintf(fid,'ENDDATA');
fclose(fid);

% read the data using BdfLines.m
bdfLines = BdfLines(fullfile(testDir1,test_file));

% check the last warning
lastmsg = lastwarn();
assert(strcmp(lastmsg,'The input file ended before the ENDDATA statement.'))

