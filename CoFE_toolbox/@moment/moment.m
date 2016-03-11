% Class for MOMENT entries
% Anthony Ricciardi
%
classdef moment < applied_load
   
    % entry data
    properties
        SID
        G
        M
        N1
        N2
        N3
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.SID = set_data('MOMENT','SID',data{2},'int',[],1);
            obj.G = set_data('MOMENT','G',data{3},'int',[],1);
            CID = set_data('MOMENT','CID',data{4},'int',0);
            if CID ~= 0; error('Nonzero MOMENT CID not supported.'); end
            
            obj.M = set_data('MOMENT','M',data{5},'dec',[]);
            obj.N1 = set_data('MOMENT','N1',data{6},'dec',[]);
            obj.N2 = set_data('MOMENT','N2',data{7},'dec',[]);
            obj.N3 = set_data('MOMENT','N3',data{8},'dec',[]);
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'MOMENT,%d,%d,,%f,%f,%f,%f\n',obj.SID,obj.G,obj.M,obj.N1,obj.N2,obj.N3);
        end
        
        %%
        function [p,gdof]=apply(obj,FEM)
            
            % gdof
            h = find(FEM.gnum==obj.G);
            if size(h,2)~=1; error(['A MOMENT entry references a GRID entry with ID#',num2str(obj.G),'.  There should be one and only one GRID with ID# ',num2str(obj.G)]); end
            gdof = FEM.gnum2gdof(4:6,h);
            
            % applied load
            p = obj.M*[obj.N1;obj.N2;obj.N3];
        end
        
    end
    
end

