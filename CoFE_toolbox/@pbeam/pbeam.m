classdef pbeam
    % Defines the properties of a beam element (CBEAM entry). Tapered beams are not supported.
    % Anthony Ricciardi
    
    % entry data
    properties
        PID
        MID
        A
        I1
        I2
        I12
        J
        NSM
        C1
        C2
        D1
        D2
        E1
        E2
        F1
        F2
        K1
        K2
    end
    
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.PID  = set_data('PBEAM','PID',data{2},'int',[],1);
            obj.MID  = set_data('PBEAM','MID',data{3},'int',[] ,1);
            obj.A    = set_data('PBEAM','A',data{4},'dec',[]);
            obj.I1   = set_data('PBEAM','I1',data{5},'dec',[]);
            obj.I2   = set_data('PBEAM','I2',data{6},'dec',[]);
            obj.I12  = set_data('PBEAM','I12',data{7},'dec',0.0);
            if obj.I12 ~= 0; errro('Nonzero I12 field on PBEAM entry not supported'); end
            obj.J    = set_data('PBEAM','J',data{8},'dec',[]);
            obj.NSM = set_data('PBEAM','NSM',data{9},'dec',0.0);
            
            if size(data,2)>10
                obj.C1 = set_data('PBEAM','C1',data{12},'dec',0.0);
                obj.C2 = set_data('PBEAM','C2',data{13},'dec',0.0);
                obj.D1 = set_data('PBEAM','D1',data{14},'dec',0.0);
                obj.D2 = set_data('PBEAM','D2',data{15},'dec',0.0);
                obj.E1 = set_data('PBEAM','E1',data{16},'dec',0.0);
                obj.E2 = set_data('PBEAM','E2',data{17},'dec',0.0);
                obj.F1 = set_data('PBEAM','F1',data{18},'dec',0.0);
                obj.F2 = set_data('PBEAM','F2',data{19},'dec',0.0);
            else
                obj.C1 = 0.0;
                obj.C2 = 0.0;
                obj.D1 = 0.0;
                obj.D2 = 0.0;
                obj.E1 = 0.0;
                obj.E2 = 0.0;
                obj.F1 = 0.0;
                obj.F2 = 0.0;
            end
            
            if size(data,2)>20
                obj.K1 = set_data('PBEAM','K1',data{22},'dec',1.0);
                obj.K2 = set_data('PBEAM','K2',data{23},'dec',1.0);
            else
                obj.K1 = 1.0;
                obj.K2 = 1.0;
            end
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'PBEAM,%d,%d,%f,%f,%f,%f,%f,%f\n',obj.PID,obj.MID,obj.A,obj.I1,obj.I2,obj.I12,obj.J,obj.NSM);
            fprintf(fid,',%d,%d,%d,%d,%d,%d,%d,%d\n',obj.C1,obj.C2,obj.D1,obj.D2,obj.E1,obj.E2,obj.F1,obj.F2);
            fprintf(fid,',%d,%d\n',obj.K1,obj.K2);
        end
    end
    
end

