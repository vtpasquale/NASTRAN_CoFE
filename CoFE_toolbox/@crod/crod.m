% Class for CROD entries
% A tension-compression-torsion element
% Anthony Ricciardi
%
classdef crod < structure & static_recover
    
    %% input data
    properties
        EID
        PID
        G1
        G2
    end
    
    %% model
    properties (Access = public)
        % element universal
        ke;   % [12x12] element stiffness matrix in global reference frame
        me;   % [12x12] element mass matrix in global reference frame
        kd;   % [12x12] element differential stiffness in global reference frame
        kd_unit_p;   % [12x12] element differential stiffness for unit axial force in global reference frame
        gdof;         % [12x1] global index numbers of element dof
    end
    properties (Access = private)
        % element only
        x1    % [3x1] node 1 position
        x2    % [3x1] node 2 position
        force_stress % [1x12] force -> stress matrix
        R % [12x12] rotation matrix from element to global reference frame
    end
    
    %% solution
    properties
        force % [12x1] element forces in element reference frame
        stress %[scaler] element axail stress
    end
    
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.EID = set_data('CROD','EID',data{2},'int',[],1,100000000);
            obj.PID = set_data('CROD','PID',data{3},'int',[] ,1);
            obj.G1 = set_data('CROD','G1',data{4},'dec',[],1);
            obj.G2 = set_data('CROD','G2',data{5},'dec',[],1);
            if obj.G1 == obj.G2
                error('G1 and G2 fields must be unique on CROD entries.')
            end
        end
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CROD,%d,%d,%d,%d\n',obj.EID,obj.PID,obj.G1,obj.G2);
        end
    end
    
end
