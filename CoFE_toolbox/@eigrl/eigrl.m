classdef eigrl
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    % file format data
    properties (Constant = true)
        minRows = 1;
        maxRows = 1;
        fields = {'EIGRL','SID','','','ND','','','',''};
        dataType = {'str','int','int','int','int','int','int','int','int'};
        default = {Inf,[],Inf,Inf,[],Inf,Inf,Inf,Inf};
    end
    % entry data
    properties
        SID % Set identification number. (Unique Integer > 0)
        ND % Number of roots desired. Integer.
    end
    
    methods
        
        function obj = initialize(obj,data)
            obj.SID = set_data('EIGRL','SID',data{2},'int',[],1);
            obj.ND = set_data('EIGRL','ND',data{5},'int',[],1);
        end
    end
end

