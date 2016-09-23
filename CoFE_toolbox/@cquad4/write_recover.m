function write_recover(obj_array,fid)

numCquad4 = size(obj_array,2);

%% S T R E S S E S      I N      Q U A D R I L A T E R A L      E L E M E N T S ( Q U A D 4 )
ct = 0;
m = 1;
for i = 1:numCquad4
    
    if ct == 0
        fprintf(fid,'\n\n         S T R E S S E S   I N   Q U A D R I L A T E R A L   E L E M E N T S ( Q U A D 4 )\n');
        ct = 12;
    end

    ct = ct - 1;
    % nodes and coordinates
    EID = obj_array(i).EID;
    t = obj_array(i).t;
    t_2 = .5*obj_array(i).tc;
    
    vs = obj_array(i).voigtStress;
    vms = obj_array(i).vonMisesStress;
    ps = obj_array(i).principalStress;
    pa = (180/pi)*obj_array(i).principalAngle;
        
    fprintf(fid,'  ELEMENT\t\t\tFIBER    \t\t\t STRESSES IN ELEMENT COORD \t\t\t SYSTEM PRINCIPAL STRESSES (ZERO SHEAR)\n');
    fprintf(fid,'    ID\tGRID-ID   DISTANCE \t\t NORMAL-X\t\t NORMAL-Y \t\t SHEAR-XY \t\t ANGLE \t\t\t MAJOR \t\t\t MINOR \t\t\t VON MISES\n');
    fprintf(fid,'\t%d\tCEN/4\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',EID,-t_2,vs([1,2,6],m,1),pa(m,1),ps([1,3],m,1),vms(m,1));
    fprintf(fid,'\t\t\t\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',          t_2,vs([1,2,6],m,2),pa(m,2),ps([1,3],m,2),vms(m,2));

    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t%d\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',obj_array(i).G1,-.5*t(1),vs([1,2,6],m,3),pa(m,3),ps([1,3],m,3),vms(m,3));
    fprintf(fid,'\t\t\t\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',                   .5*t(1),vs([1,2,6],m,4),pa(m,4),ps([1,3],m,4),vms(m,4));
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t%d\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',obj_array(i).G2,-.5*t(2),vs([1,2,6],m,5),pa(m,5),ps([1,3],m,5),vms(m,5));
    fprintf(fid,'\t\t\t\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',                   .5*t(2),vs([1,2,6],m,6),pa(m,6),ps([1,3],m,6),vms(m,6));
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t%d\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',obj_array(i).G3,-.5*t(3),vs([1,2,6],m,7),pa(m,7),ps([1,3],m,7),vms(m,7));
    fprintf(fid,'\t\t\t\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',                   .5*t(3),vs([1,2,6],m,8),pa(m,8),ps([1,3],m,8),vms(m,8));
    fprintf(fid,'\n');
    fprintf(fid,'\t\t\t%d\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',obj_array(i).G4,-.5*t(4),vs([1,2,6],m,9),pa(m,9),ps([1,3],m,9),vms(m,9));
    fprintf(fid,'\t\t\t\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\t%+E\n',                  .5*t(4),vs([1,2,6],m,10),pa(m,10),ps([1,3],m,10),vms(m,10));
    fprintf(fid,'\n\n\n');
end
end