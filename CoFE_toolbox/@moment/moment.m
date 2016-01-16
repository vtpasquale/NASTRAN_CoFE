% Class for MOMENT entries
% Anthony Ricciardi
%
classdef moment < entry
   
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
            obj.SID = set_data('MOMENT','SID',data{2},'int',[],1);
            obj.G = set_data('MOMENT','G',data{3},'int',[],1);
            CID = set_data('MOMENT','CID',data{4},'int',0);
            if CID ~= 0; error('Nonzero MOMENT CID not supported.'); end
            
            obj.F = set_data('MOMENT','F',data{5},'dec',[]);
            obj.N1 = set_data('MOMENT','N1',data{6},'dec',[]);
            obj.N2 = set_data('MOMENT','N2',data{7},'dec',[]);
            obj.N3 = set_data('MOMENT','N3',data{8},'dec',[]);
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'MOMENT,%d,%d,,%f,%f,%f,%f\n',obj.SID,obj.G,obj.F,obj.N1,obj.N2,obj.N3);
        end
    end
    
end

