% Class for GRAV entries
% Anthony Ricciardi
%
classdef grav < applied_load
    
    % entry data
    properties
        SID
        CID
        A
        N1
        N2
        N3
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.SID = set_data('GRAV','SID',data{2},'int',[],1);
            obj.CID = set_data('GRAV','CID',data{3},'int',0);
            if obj.CID ~= 0; error('Nonzero GRAV CID not supported.'); end

            obj.A = set_data('GRAV','A',data{4},'dec',0);
            obj.N1 = set_data('GRAV','N1',data{5},'dec',0);
            obj.N2 = set_data('GRAV','N2',data{6},'dec',0);
            obj.N3 = set_data('GRAV','N3',data{7},'dec',0);

        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'GRAV,%d,%d,%f,%f,%f,%f\n',obj.SID,obj.CID,obj.A,obj.N1,obj.N2,obj.N3);
        end
        
        %%
        function [p,gdof]=apply(obj,FEM)
 
            % gdof
            gdof = 1:FEM.ndof;
            
            % gravitational acceleration
            gAccel = zeros(FEM.ndof,1);
            gAccel(1:6:FEM.ndof) = obj.A * obj.N1;
            gAccel(2:6:FEM.ndof) = obj.A * obj.N2;
            gAccel(3:6:FEM.ndof) = obj.A * obj.N3;
            
            % applied load
            p = FEM.M_G*gAccel;
            
        end
        
    end
end

