% Class for PROD property entries
% Anthony Ricciardi
%
classdef prod < entry
    
    % entry data
    properties
        PID
        MID
        A
        J
        NSM
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.PID = set_data('PROD','PID',data{2},'int',[],1);
            obj.MID = set_data('PROD','MID',data{3},'int',[] ,1);
            obj.A = set_data('PROD','A',data{4},'dec',[]);
            obj.J = set_data('PROD','J',data{5},'dec',[]);
            obj.NSM = set_data('PROD','NSM',data{7},'dec',0.0);
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'PROD,%d,%d,%f,%f,,%f\n',obj.PID,obj.MID,obj.A,obj.J,obj.NSM);
        end
    end
end

