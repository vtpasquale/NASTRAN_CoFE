classdef pmass
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    % file format data
    properties (Constant = true)
        minRows = 1;
        maxRows = 1;
        fields = {'PMASS','PID1','M1',[],[],[],[],[],[]};
        dataType = {'str','int','dec',[],[],[],[],[],[]};
        default = {Inf,[],[],Inf,Inf,Inf,Inf,Inf,Inf};       
    end
    % entry data
    properties
        PID1
        M1
    end
    
    methods
        function obj = initialize(obj,data)
            obj.PID1 = set_data('PMASS','PID1',data{2},'int',[],1);
            obj.M1 = set_data('PMASS','M1',data{3},'dec',[]);
            if strcmp(data{4},'') == 0
                error('CoFE does not allow PID2 field on PMASS entries.')
            end
        end
        
        function echo(obj,fid)
            fprintf(fid,'PMASS,%d,%f\n',obj.PID1,obj.M1);
        end
    end
    
end

