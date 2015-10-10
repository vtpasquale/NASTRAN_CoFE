classdef pbeaml
    % Summary of this class goes here
    %   Detailed explanation goes here
    
    % entry data
    properties
        PID
        MID
        TYPE
        DIM1
        DIM2
        NSM
    end
    % derived properties
    properties
        A
        I1
        I2
        I12
        J
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
        function obj = initialize(obj,data)
            obj.PID = set_data('PBEAML','PID',data{2},'int',[],1);
            obj.MID = set_data('PBEAML','MID',data{3},'int',[],1);
            obj.TYPE = set_data('PBEAML','TYPE',data{5},'str',[]);
            obj.DIM1 = set_data('PBEAML','DIM1',data{12},'dec',[]);
            switch obj.TYPE
                case 'BAR'
                    obj.DIM2 = set_data('PBEAML','DIM2',data{13},'dec',[]);
                    obj.NSM = set_data('PBEAML','NSM',data{14},'dec',0.0);
                case 'ROD'
                    obj.NSM = set_data('PBEAML','NSM',data{13},'dec',0.0);
                otherwise
                    error(['PBEAML TYPE ',obj.TYPE,' not supported'])
            end
        end
        
        function echo(obj,fid)
            fprintf(fid,'RBE3,%d,,%d,%d,%f,%d,%d,%d\n',obj.EID,obj.REFGRID,obj.REFC,obj.WT1,obj.C1,obj.G1,obj.G2);
        end
    end
    
end

