% Class for zero displacement single-point constraints
% Anthony Ricciardi
%
classdef spc1 < entry
    
    % entry data
    properties
        SID
        C
        G1
    end
    methods
        function obj = initialize(obj,data)
            obj.SID = set_data('SPC1','SID',data{2},'int',[],1);
            obj.C   = set_data('SPC1','C',data{3},'int',[],1);
            obj.G1  = set_data('SPC1','G1',data{4},'int',[],1);
            
            if isempty(data{5}) ~= 1
                if strcmp(data{5},'') ~= 1
                    error('CoFE does not allow G2 field on SPC1 entries.')
                end
            end
        end
        
        function echo(obj,fid)
            fprintf(fid,'SPC1,%d,%d,%d\n',obj.SID,obj.C,obj.G1);
        end
    end
end

