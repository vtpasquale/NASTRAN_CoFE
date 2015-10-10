classdef pshell
    %PSHELL Summary of this class goes here
    %   Detailed explanation goes here

    properties
        PID
        MID1
        T
        MID2
        n12I_Tpwr3
        MID3
        TS_T
        NSM
        Z1 
        Z2 
        MID4
    end
    
    methods
        function obj = initialize(obj,data)
            obj.PID  = set_data('PSHELL','PID',data{2},'int',[],1);
            obj.MID1 = set_data('PSHELL','MID1',data{3},'int',[] ,1);
            obj.T    = set_data('PSHELL','T',data{4},'dec',-999);
            obj.MID2 = set_data('PSHELL','MID2',data{5},'int',-999 ,-1);
            obj.n12I_Tpwr3 = set_data('PSHELL','12I/T**3',data{6},'dec',1.0,eps);
            obj.MID3 = set_data('PSHELL','MID3',data{7},'int',-999 ,1);
            obj.TS_T = set_data('PSHELL','TS_T',data{8},'dec',1/1.2,eps);
            obj.NSM = set_data('PSHELL','NSM',data{9},'dec',0.0,0.0);
            
            if size(data,2)>10
                obj.Z1 = set_data('PSHELL','Z1',data{12},'dec',obj.T/2);
                obj.Z2 = set_data('PSHELL','Z2',data{13},'dec',obj.T/2);
                obj.MID4 = set_data('PSHELL','MID4',data{14},'int',-999 ,1);
            else
                obj.Z1 = [];
                obj.Z2 = [];
                obj.MID4 = [];
            end
        end
    end
    
end