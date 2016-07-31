% Class for BLIQ entries - Canfield membrane element
% Anthony Ricciardi
%
classdef bliq  < structure
    
    % fundamental data (from input file)
    properties
        EID
        PID
        G1
        G2
        G3
        G4
    end
    % mesh quantities
    properties
        x1 % undeformed global position of nodes
        x2
        x3
        x4
        gdof % global degrees of freedom
        G    % stress-strain matrix -> from MAT1
    end
    % derived physical quantities
    properties
        ke
        me
        stress
    end
    methods
        
        %%
        function obj = initialize(obj,data)
            obj.EID  = set_data('BLIQ','EID',data{2},'int',[],1,100000000);
            obj.PID  = set_data('BLIQ','PID',data{3},'int',obj.EID ,1);
            obj.G1   = set_data('BLIQ','G1',data{4},'int',1);
            obj.G2   = set_data('BLIQ','G2',data{5},'int',1);
            obj.G3   = set_data('BLIQ','G3',data{6},'int',1);
            obj.G4   = set_data('BLIQ','G4',data{7},'int',1);
            if any(obj.G1==[obj.G2,obj.G3,obj.G4]) || any(obj.G2==[obj.G3,obj.G4]) || obj.G3==obj.G4 % if size(unique([obj.G1,obj.G2,obj.G3,obj.G4])) < 4
                error('BLIQ nodes G1-G4 must be unique')
            end
        end
        
        %% 
        function [obj,obj_prime] = differential(obj,obj_prime)
            error('Buckling analysis not supported for BLIQ elements.')
        end
        
        %%
        function write_recover(obj_array,fid)
            error('write_recover not implimented for BLIQ elements.  This could be implimented quickly. Alternatively, set CASE.WRITE_c06 = 0;')
        end 
        
        %%
        function echo(obj,fid)
            fprintf(fid,'BLIQ,%d,%d,%d,%d,%d,%d\n',obj.EID,obj.PID,obj.G1,obj.G2,obj.G3,obj.G4);
        end
    end    
end

