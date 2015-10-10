classdef cmass1
    % Summary of this class goes here
    %   Detailed explanation goes here
    
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
        x1
        ke
        me
        kd
    end
    methods
        function obj = initialize(obj,data)
            obj.EID = set_data('CMASS1','EID',data{2},'int',[],1,100000000);
            obj.PID = set_data('CMASS1','PID',data{3},'int',[] ,1);
            obj.G1 = set_data('CMASS1','G1',data{4},'int',[],1);
            obj.C1 = set_data('CMASS1','C1',data{5},'int',[],1,6);
            if strcmp(data{6},'') == 0
                error('CoFE does not allow G2 field on CMASS1 entries.')
            end
        end
        
        function plot(obj,gnum,gnum2gdof,allDef,varargin)
            if isempty(gnum2gdof);
                def = zeros(3,1);
            else
                def = allDef(gnum2gdof(1:3,find(gnum==obj.G1)));
            end
            
            % point
            p = obj.x1 + def;
            plot3(p(1,:),p(2,:),p(3,:),varargin{:})
        end
        
        function echo(obj,fid)
            fprintf(fid,'CMASS1,%d,%d,%d,%d\n',obj.EID,obj.PID,obj.G1,obj.C1);
        end
    end
end
    
