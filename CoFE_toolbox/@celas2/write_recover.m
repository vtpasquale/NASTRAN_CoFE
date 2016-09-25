function write_recover(obj_array,fid)
% 
% numCrod = size(obj_array,2);
% %%    F O R C E S   I N   R O D   E L E M E N T S     ( C R O D )
% ct = 0;
% for i = 1:1:numCrod
% 
%     if ct == 0
%         fprintf(fid,'\n\n         F O R C E S   I N   R O D   E L E M E N T S     ( C R O D )\n');
%         fprintf(fid,'    ELEMENT       AXIAL                             ELEMENT           AXIAL\n');
%         fprintf(fid,'      ID.         FORCE          TORQUE               ID.             FORCE          TORQUE\n');
%         ct = 24;
%     end
% 
%     ct = ct - 1;
%     
%     % nodes and coordinates
%     fprintf(fid,' %8d \t\t %+E \t %+E',obj_array(i).EID,obj_array(i).force(7),obj_array(i).force(10));
%     if mod(i,2) == 1
%         fprintf(fid,'\t');
%     else
%         fprintf(fid,'\n');
%     end
% end
% 
% %% S T R E S S E S   I N   R O D   E L E M E N T S      ( C R O D )
% ct = 0;
% for i = 1:1:numCrod
% 
%     if ct == 0
%         fprintf(fid,'\n\n         S T R E S S E S   I N   R O D   E L E M E N T S      ( C R O D )\n');
%         fprintf(fid,'    ELEMENT       AXIAL         TORSIONAL           ELEMENT           AXIAL        TORSIONAL\n');
%         fprintf(fid,'      ID.        STRESS          STRESS               ID.            STRESS          STRESS\n');
%         ct = 24;
%     end
% 
%     ct = ct - 1;
%     % nodes and coordinates
%     fprintf(fid,' %8d \t\t %+E \t\t\t %s',obj_array(i).EID,obj_array(i).stress,'N/A');
%     if mod(i,2) == 1
%         fprintf(fid,'\t');
%     else
%         fprintf(fid,'\n');
%     end
% end


end

