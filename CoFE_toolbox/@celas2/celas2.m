% Class for CELAS2 entries
% Anthony Ricciardi
%
classdef celas2 < structure
    
    % entry data
    properties
        EID
        K
        G1
        C1
        G2
        C2
    end
    % derived properties
    properties
        gdof
        gdof_plot
        x1
        x2
        ke
        me
        kd
    end
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.EID = set_data('CELAS2','EID',data{2},'int',[],1,100000000);
            obj.K = set_data('CELAS2','K',data{3},'dec',[]);
            obj.G1 = set_data('CELAS2','G1',data{4},'int',[],1);
            obj.C1 = set_data('CELAS2','C1',data{5},'int',[],1,6);
            obj.G2 = set_data('CELAS2','G2',data{6},'int',[],1);
            obj.C2 = set_data('CELAS2','C2',data{7},'int',[],1,6);
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CELAS2,%d,%f,%d,%d,%d,%d\n',obj.EID,obj.K,obj.G1,obj.C1,obj.G2,obj.C2);
        end
    end
end
    
