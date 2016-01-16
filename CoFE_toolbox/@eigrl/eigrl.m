% Class for FORCE entries
% Anthony Ricciardi
%
classdef eigrl < entry
    
    % entry data
    properties
        SID % Set identification number. (Unique Integer > 0)
        ND % Number of roots desired. Integer.
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.SID = set_data('EIGRL','SID',data{2},'int',[],1);
            obj.ND = set_data('EIGRL','ND',data{5},'int',[],1);
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'EIGRL,%d,,,%d\n',obj.SID,obj.ND);
        end
        
    end
end

