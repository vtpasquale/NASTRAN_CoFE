% Class for CTRIA3 entries
% Anthony Ricciardi
%
classdef ctria3 < structure & plot2D
    
    % fundamental data (from input file)
    properties
        EID
        PID
        G1
        G2
        G3
        THETA
        ZOFFS
        TFLAG
        T1
        T2
        T3
    end
    
    % mesh quantities
    properties (SetAccess = private)
        gdof
    end
    properties (SetAccess = private, GetAccess = ?plot2D)
        gdofTranslational = [(1:3)',(7:9)',(13:15)',(13:15)'];  % used for plotting, last node repeat to get cquad4 plots to work
    end
    properties (SetAccess = private, GetAccess = ?plot2D)
        x1 % undeformed global position of nodes
        x2
        x3
        x4
    end
    properties
        XE
        n1 % surface normals and nodes
        n2
        n3
        G % stress-strain matrix -> from MAT1 and PSHELL
        A % rotation transformation matricies at nodes
        t % [4x1] element thicknesses at nodes
        NSM % nonstructural mass
        rho % material density
        CBB % strain-displacement matrices at the bottom of the element midpoint
        CBT % strain-displacement matrices at the top of the element midpoint
        N1BB % strain-displacement matrices at nodes
        N1BT
        N2BB
        N2BT
        N3BB
        N3BT
        tc  % thickness at element element center
        voigtStress % [6 x nm x 10] Matrix of stress vectors in Voigt notation [[s11 s22 s33 s23 s13 s12]' x nm x [recovery points]], where nm is the number of response modes.
        voigtStrain % [6 x nm x 10] Matrix of strain vectors in Voigt notation [[e11 e22 e33 e23 e13 e12]' x nm x [recovery points]], where nm is the number of response modes.
                    % were recovery points are:
                    % [centerBot % [responsePoint] response recovery point at element center bottom surface
                    %  centerTop % [responsePoint] response recovery point at element center top surface
                    %  N1Bot % [responsePoint] response recovery points at nodes
                    %  N1Top
                    %  N2Bot
                    %  N2Top
                    %  N3Bot
                    %  N3Top]
    end
    properties (Constant = true, Hidden = true)
        TAI = [eye(3),zeros(3);zeros(3),[0 1 0; -1 0 0; 0 0 1]];
    end
    % physical quantities
    properties
        ke
        me
        ese
        eke
        stress
    end
    methods
        %%
        function obj = initialize(obj,data)
            obj.EID  = set_data('CTRIA3','EID',data{2},'int',[],1,100000000);
            obj.PID  = set_data('CTRIA3','PID',data{3},'int',obj.EID ,1);
            obj.G1   = set_data('CTRIA3','G1',data{4},'int',1);
            obj.G2   = set_data('CTRIA3','G2',data{5},'int',1);
            obj.G3   = set_data('CTRIA3','G3',data{6},'int',1);
            if any(obj.G1==[obj.G2,obj.G3]) || any(obj.G2==[obj.G3]) % if size(unique([obj.G1,obj.G2,obj.G3])) < 3
                error('CTRIA3 nodes G1-G3 must be unique')
            end
            obj.THETA = set_data('CTRIA3','THETA',data{7},'dec',0.0);
            obj.ZOFFS = set_data('CTRIA3','ZOFFS',data{8},'dec',0.0);
            if obj.ZOFFS ~= 0
                error('Nonzero ZOFFS not supported')
            end
            
            if size(data,2)>10
                obj.TFLAG = set_data('CTRIA3','TFLAG',data{13},'int',0);
                if obj.TFLAG ~= 0 && obj.TFLAG ~= 1
                    error('CQUAD entry TFLAG field should be zero or one.')
                end
                obj.T1 = set_data('CTRIA3','T1',data{14},'dec',1.0);
                obj.T2 = set_data('CTRIA3','T2',data{15},'dec',1.0);
                obj.T3 = set_data('CTRIA3','T3',data{16},'dec',1.0);
            else
                obj.TFLAG = int32(-999);
                obj.T1 = 1.0;
                obj.T2 = 1.0;
                obj.T3 = 1.0;
            end
        end
        
        %% 
        function [obj,obj_prime] = differential(obj,obj_prime)
            error('Buckling analysis not supported for CTRIA3 elements')
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CTRIA3,%d,%d,%d,%d,%d,%f,%f\n',obj.EID,obj.PID,obj.G1,obj.G2,obj.G3,obj.THETA,obj.ZOFFS);
            if obj.TFLAG ~= -999
                fprintf(fid,',,%d,%f,%f,%f\n',obj.TFLAG,obj.T1,obj.T2,obj.T3);
            end
        end
    end    
end

