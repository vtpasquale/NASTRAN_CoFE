function write_recover(obj_array,fid)

numCquad4 = size(obj_array,2);

%% S T R E S S E S      I N      Q U A D R I L A T E R A L      E L E M E N T S ( Q U A D 4 )
ct = 0;
for i = 1:numCquad4
    
    if ct == 0
        fprintf(fid,'\n\n         S T R E S S E S   I N   Q U A D R I L A T E R A L   E L E M E N T S ( Q U A D 4 )\n');
        ct = 12;
    end

    ct = ct - 1;
    % nodes and coordinates
    EID = obj_array(i).EID;
    t_2 = .5*obj_array(i).tc;
    
    try
    fprintf(fid,'   ELEMENT \t   FIBER    \t\t\t STRESSES IN ELEMENT COORD \t\t\t SYSTEM PRINCIPAL STRESSES (ZERO SHEAR)\n');
    fprintf(fid,'     ID  \t DISTANCE \t\t NORMAL-X \t NORMAL-Y \t\t SHEAR-XY \t\t ANGLE \t\t\t MAJOR \t\t\t MINOR \t\t\t VON MISES\n');
    fprintf(fid,'\t%d\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',EID,-t_2,obj_array(i).stress([1:3,6:9],1));
    fprintf(fid,'\t\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',       t_2,obj_array(i).stress([1:3,6:9],2));
    catch
        keyboard
    end
end
end