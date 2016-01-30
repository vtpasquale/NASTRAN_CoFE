% Class for FORCE entries
% Anthony Ricciardi
%
classdef force < applied_load
   
    % entry data
    properties
        SID
        G
        F
        N1
        N2
        N3
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.SID = set_data('FORCE','SID',data{2},'int',[],1);
            obj.G = set_data('FORCE','G',data{3},'int',[],1);
            CID = set_data('FORCE','CID',data{4},'int',0);
            if CID ~= 0; error('Nonzero FORCE CID not supported.'); end
            
            obj.F = set_data('FORCE','F',data{5},'dec',[]);
            obj.N1 = set_data('FORCE','N1',data{6},'dec',[]);
            obj.N2 = set_data('FORCE','N2',data{7},'dec',[]);
            obj.N3 = set_data('FORCE','N3',data{8},'dec',[]);
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'FORCE,%d,%d,,%f,%f,%f,%f\n',obj.SID,obj.G,obj.F,obj.N1,obj.N2,obj.N3);
        end
        
        %%
        function [p,gdof]=apply(obj,FEM)
            
            % gdof
            h = find(FEM.gnum==obj.G);
            if size(h,2)~=1; error(['A FORCE entry references a GRID entry with ID#',num2str(obj.G),'.  There should be one and only one GRID with ID# ',num2str(obj.G)]); end
            gdof = FEM.gnum2gdof(1:3,h);
            
            % applied load
            p = obj.F*[obj.N1;obj.N2;obj.N3];
        end
            
    end
    
end

