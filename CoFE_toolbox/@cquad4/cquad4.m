% Class for CQUAD4 entries
% Anthony Ricciardi
%
classdef cquad4 < structure
    
    % fundamental data (from input file)
    properties
        EID
        PID
        G1
        G2
        G3
        G4
        THETA
        ZOFFS
        TFLAG
        T1
        T2
        T3
        T4
    end
    
    % mesh quantities
    properties
        x1 % undeformed global position of nodes
        x2
        x3
        x4
        XE
        gdof
        n1 % surface normals and nodes
        n2
        n3
        n4
        G % stress-strain matrix -> from MAT1 and PSHELL
        A % rotation transformation matricies at nodes
        t % [4x1] element thicknesses at nodes
        NSM % nonstructural mass
        rho % material density
        CBB % strain-displacement matricies at the bottom of the element midpoint
        CBT % strain-displacement matricies at the top of the element midpoint
        N1BB % strain-displacement matricies at nodes
        N1BT
        N2BB
        N2BT
        N3BB
        N3BT
        N4BB
        N4BT
        tc  % thickness at element element center
        centerBot % [responsePoint] response recovery point at element center bottom surface
        centerTop % [responsePoint] response recovery point at element center top surface
        N1Bot % [responsePoint] response recovery points at nodes
        N1Top
        N2Bot
        N2Top
        N3Bot
        N3Top
        N4Bot
        N4Top
    end
    
    % physical quantities
    properties
        ke
        me
        stress
    end
    methods
        %%
        function obj = initialize(obj,data)
            obj.EID  = set_data('CQUAD4','EID',data{2},'int',[],1,100000000);
            obj.PID  = set_data('CQUAD4','PID',data{3},'int',obj.EID ,1);
            obj.G1   = set_data('CQUAD4','G1',data{4},'int',1);
            obj.G2   = set_data('CQUAD4','G2',data{5},'int',1);
            obj.G3   = set_data('CQUAD4','G3',data{6},'int',1);
            obj.G4   = set_data('CQUAD4','G4',data{7},'int',1);
            if any(obj.G1==[obj.G2,obj.G3,obj.G4]) || any(obj.G2==[obj.G3,obj.G4]) || obj.G3==obj.G4 % if size(unique([obj.G1,obj.G2,obj.G3,obj.G4])) < 4
                error('CQUAD4 nodes G1-G4 must be unique')
            end
            obj.THETA = set_data('CQUAD4','THETA',data{8},'dec',0.0);
            obj.ZOFFS = set_data('CQUAD4','ZOFFS',data{9},'dec',0.0);
            if obj.ZOFFS ~= 0
                error('Nonzero ZOFFS not supported')
            end
            
            if size(data,2)>10
                obj.TFLAG = set_data('CQUAD4','TFLAG',data{13},'int',0);
                if obj.TFLAG ~= 0 && obj.TFLAG ~= 1
                    error('CQUAD entry TFLAG field should be zero or one.')
                end
                obj.T1 = set_data('CQUAD4','T1',data{14},'dec',1.0);
                obj.T2 = set_data('CQUAD4','T2',data{15},'dec',1.0);
                obj.T3 = set_data('CQUAD4','T3',data{16},'dec',1.0);
                obj.T4 = set_data('CQUAD4','T4',data{17},'dec',1.0);
            else
                obj.TFLAG = int32(-999);
                obj.T1 = 1.0;
                obj.T2 = 1.0;
                obj.T3 = 1.0;
                obj.T4 = 1.0;
            end      
        end
        
        %% 
        function [obj,obj_prime] = differential(obj,obj_prime)
            error('Buckling analysis not supported for CQUAD4 elements')
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CQUAD4,%d,%d,%d,%d,%d,%d,%f,%f\n',obj.EID,obj.PID,obj.G1,obj.G2,obj.G3,obj.G4,obj.THETA,obj.ZOFFS);
            fprintf(fid,',,%d,%f,%f,%f,%f\n',obj.TFLAG,obj.T1,obj.T2,obj.T3,obj.T4);
        end
    end    
end

