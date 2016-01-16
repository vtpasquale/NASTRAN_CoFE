function [] = write_c06(obj,outFile)

%% File extension
ext = strfind(outFile,'.bdf');
if isempty(ext)
    ext = strfind(outFile,'.dat');
    if isempty(ext)
        % can't find extension
        ext = length(outFile)+1;
    end
end
outFile = [outFile(1:ext-1),'.c06'];

%% Open file
fid = fopen(outFile,'w');

%% Title Sheet
titleString = legacy.titleSheet();
for i = 1:size(titleString,1)
    fprintf(fid,[titleString{i},'\n']);
end
% fprintf(fid,[titleString{i},'\n']);
fprintf(fid,'  This case was run %s \n',datestr(now));


%%    S T A T I C     D I S P L A C E M E N T S
if isempty(obj.x) == 0
ct = 0;
for i = 1:1:obj.nnodes
    
    if ct == 0
        fprintf(fid,'\n\n                                 S T A T I C     D I S P L A C E M E N T S\n');
        fprintf(fid,'     GRID\n');
        fprintf(fid,'      ID.              T1             T2               T3             R1               R2             R3\n');
        ct = 24;
    end

    ct = ct - 1;
    fprintf(fid,' %8d \t\t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',obj.gnum(i)...
        ,obj.x(obj.gnum2gdof(1,i)),obj.x(obj.gnum2gdof(2,i)),obj.x(obj.gnum2gdof(3,i)),...
                         obj.x(obj.gnum2gdof(4,i)),obj.x(obj.gnum2gdof(5,i)),obj.x(obj.gnum2gdof(6,i)) );
end
end

%% Element static recovery data
if obj.CASE.RECOVER == 1 && ( obj.CASE.SOL == 101 || obj.CASE.SOL == 105 )
    for j = 1:size(obj.static_recoverList,2)
        placeholderObj = obj.(obj.static_recoverList{j});
        if size(placeholderObj,2) > 0
            placeholderObj.write_recover(fid);
        end
        clear placeholderObj
    end
end

%%    V I B R A T I O N     F R E Q U E N C I E S
if isempty(obj.wHz) == 0
fprintf(fid,'\n\n                          V I B R A T I O N     F R E Q U E N C I E S \n');
fprintf(fid,' MODE NO. \t FREQUENCY (Hz) \n');
for mn = 1:obj.ND
    fprintf(fid,'\t %d \t %E \n',mn,obj.wHz(mn));
end
end

%%    V I B R A T I O N     E I G E N V E C T O R S
if isempty(obj.xm) == 0
ct = 0;
for mn = 1:obj.ND
for i = 1:obj.nnodes
    
    if ct == 0
        fprintf(fid,'\n\n                          V I B R A T I O N     E I G E N V E C T O R     N O.  %d \n',mn);
        fprintf(fid,' Frequency = %g Hz \n',obj.wHz(mn));
        fprintf(fid,'     GRID\n');
        fprintf(fid,'      ID.              T1             T2               T3             R1               R2             R3\n');
        ct = 24;
    end

    ct = ct - 1;
    fprintf(fid,' %8d \t\t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',obj.gnum(i)...
        ,obj.xm(obj.gnum2gdof(1,i),mn),obj.xm(obj.gnum2gdof(2,i),mn),obj.xm(obj.gnum2gdof(3,i),mn),...
                         obj.xm(obj.gnum2gdof(4,i),mn),obj.xm(obj.gnum2gdof(5,i),mn),obj.xm(obj.gnum2gdof(6,i),mn) );
end
ct = 0;
end
end

%%    B U C K L I N G     E I G E N V A L U E S 
if isempty(obj.Db) == 0
fprintf(fid,'\n\n                          B U C K L I N G     E I G E N V A L U E S  \n');
fprintf(fid,' MODE NO. \t EIGENVALUE \n');
for mn = 1:obj.ND
    fprintf(fid,'\t %d \t %+E \n',mn,obj.Db(mn));
end
end

%%    B U C K L I N G     E I G E N V E C T O R S
if isempty(obj.xb) == 0
ct = 0;
for mn = 1:obj.ND
for i = 1:obj.nnodes
    
    if ct == 0
        fprintf(fid,'\n\n                          B U C K L I N G     E I G E N V E C T O R     N O.  %d \n',mn);
        fprintf(fid,' Buckling Load Factor = %g \n',obj.Db(mn) );
        fprintf(fid,'     GRID\n');
        fprintf(fid,'      ID.              T1             T2               T3             R1               R2             R3\n');
        ct = 24;
    end

    ct = ct - 1;
    fprintf(fid,' %8d \t\t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',obj.gnum(i)...
        ,obj.xb(obj.gnum2gdof(1,i),mn),obj.xb(obj.gnum2gdof(2,i),mn),obj.xb(obj.gnum2gdof(3,i),mn),...
                         obj.xb(obj.gnum2gdof(4,i),mn),obj.xb(obj.gnum2gdof(5,i),mn),obj.xb(obj.gnum2gdof(6,i),mn) );                 
end
ct = 0;
end
end
