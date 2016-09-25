% Class for CONM2 entries
% Anthony Ricciardi
%
classdef conm2 < structure & plot0D
    
    % entry data
    properties
        EID
        G
        CID
        M
        X1
        X2
        X3
        I11
        I21
        I22
        I31
        I32
        I33
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
    properties
        eke % [nm x 1] element modal kinetic energy
        ese % [nm x 1] element static or modal strain energy
        voigtStress	= [];
        voigtStrain	= [];
    end
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.EID = set_data('CONM2','EID',data{2},'int',[],1,100000000);
            obj.G = set_data('CONM2','G',data{3},'int',[] ,1);
            obj.CID = set_data('CONM2','CID',data{4},'int',0,-1);
                if obj.CID ~= 0
                    error('CONM2 ',num2str(obj.EID),' has nonzero CID.  CID should be zero or blank.');
                end
            obj.M  = set_data('CONM2','M',data{5},'dec',[]);
            obj.X1 = set_data('CONM2','X1',data{6},'dec',0.0);
            obj.X2 = set_data('CONM2','X2',data{7},'dec',0.0);
            obj.X3 = set_data('CONM2','X3',data{8},'dec',0.0);
            if size(data,2)>10
                obj.I11 = set_data('CONM2','I11',data{12},'dec',0.0);
                obj.I21 = set_data('CONM2','I21',data{13},'dec',0.0);
                obj.I22 = set_data('CONM2','I22',data{14},'dec',0.0);
                obj.I31 = set_data('CONM2','I31',data{15},'dec',0.0);
                obj.I32 = set_data('CONM2','I32',data{16},'dec',0.0);
                obj.I33 = set_data('CONM2','I33',data{17},'dec',0.0);
            else
                obj.I11 = 0.0;
                obj.I21 = 0.0;
                obj.I22 = 0.0;
                obj.I31 = 0.0;
                obj.I32 = 0.0;
                obj.I33 = 0.0;
            end
            
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CONM2,%d,%d,%d,%f,%f,%f,%f\n',obj.EID,obj.G,obj.CID,obj.M,obj.X1,obj.X2,obj.X3);
            if size(data,2)>10
                fprintf(fid,',%f,%f,%f,%f,%f,%f\n',obj.I11,obj.I21,obj.I22,obj.I31,obj.I32,obj.I33);
            end
        end
    end
end
    
