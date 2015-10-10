function write_recover(obj_array,fid)

numCbeam = size(obj_array,2);

%%   F O R C E S   I N   B E A M   E L E M E N T S        ( C B E A M )
ct = 0;
for i = 1:numCbeam
    
    if ct == 0
        fprintf(fid,'\n\n         F O R C E S   I N   B E A M   E L E M E N T S        ( C B E A M )\n');
        fprintf(fid,'                       - BENDING MOMENTS -              - WEB  SHEARS -              AXIAL          TOTAL\n');
        fprintf(fid,'ELEMENT-ID  GRID     PLANE 1         PLANE 2        PLANE 1         PLANE 2          FORCE          TORQUE\n');
        ct = 12;
    end

    ct = ct - 1;
    % nodes and coordinates
    nnum1 = obj_array(i).GA;
    nnum2 = obj_array(i).GB;
    EID = obj_array(i).EID;
       
    fprintf(fid,' %d\n',EID);
    fprintf(fid,'\t\t %d \t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',nnum1,-obj_array(i).force(6),-obj_array(i).force(5),-obj_array(i).force(2),-obj_array(i).force(3),-obj_array(i).force(1),-obj_array(i).force(4));
    fprintf(fid,'\t\t %d \t %+E \t %+E \t %+E \t %+E \t %+E \t %+E \n',nnum2,obj_array(i).force(12), obj_array(i).force(11),obj_array(i).force(8),obj_array(i).force(9),obj_array(i).force(7),obj_array(i).force(10));
end


%% S T R E S S E S   I N   B E A M   E L E M E N T S        ( C B E A M )
ct = 0;
for i = 1:numCbeam
    
    if ct == 0
        fprintf(fid,'\n\n         S T R E S S E S   I N   B E A M   E L E M E N T S        ( C B E A M )\n');
        fprintf(fid,'ELEMENT-ID GRID       SXC             SXD             SXE             SXF\n');
        ct = 12;
    end

    ct = ct - 1;
    % nodes and coordinates
    nnum1 = obj_array(i).GA;
    nnum2 = obj_array(i).GB;
    EID = obj_array(i).EID;
    
    fprintf(fid,' %d\n',EID);
    fprintf(fid,'\t\t %d \t %+E \t %+E \t %+E \t %+E\n',nnum1,obj_array(i).stress(:,1));
    fprintf(fid,'\t\t %d \t %+E \t %+E \t %+E \t %+E\n',nnum2,obj_array(i).stress(:,2));
end

end