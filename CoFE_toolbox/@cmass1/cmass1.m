% Class for CMASS1 entries
% Anthony Ricciardi
%
classdef cmass1 < structure & plot0D
    
    % entry data
    properties
        EID
        PID
        G1
        C1
    end
    % derived properties
    properties
        gdof
        ke
        me
        kd
    end
    properties (SetAccess = private, GetAccess = ?plot0D)
        x1
        gdof_plot
    end
    % solution
    properties
        eke % [nm x 1] element modal kinetic energy
        ese % [nm x 1] element static or modal strain energy
    end
    properties
        voigtStress	= [];
        voigtStrain	= [];
    end
    
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.EID = set_data('CMASS1','EID',data{2},'int',[],1,100000000);
            obj.PID = set_data('CMASS1','PID',data{3},'int',[] ,1);
            obj.G1 = set_data('CMASS1','G1',data{4},'int',[],1);
            obj.C1 = set_data('CMASS1','C1',data{5},'int',[],1,6);
            if strcmp(data{6},'') == 0
                error('CoFE does not allow G2 field on CMASS1 entries.')
            end
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CMASS1,%d,%d,%d,%d\n',obj.EID,obj.PID,obj.G1,obj.C1);
        end
    end
end
    
