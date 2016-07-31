% Class for CBEAM entries 
% Anthony Ricciardi
%
classdef cbeam < structure

    %% input data
    properties
        EID
        PID
        GA
        GB
        X1
        X2
        X3
    end
    
    %% model
    properties (Access = public)
        % element universal
        ke;     % [12x12] element stiffness matrix in global reference frame
        me;     % [12x12] element mass matrix in global reference frame
        kd;     % [12x12] element differential matrix in global reference frame
        
        kdp     % [12x12] element unit-load differential stiffness matrices in global reference frame
        kdvy
        kdvz
        kdmy2
        kdmz2
        kdmx
        gdof;   % [12x1] global index numbers of element dof
    end
    properties (Access = private)
        % element only
        x1    % [3x1] node 1 position
        x2    % [3x1] node 2 position
        force_stress % [1x12] force -> stress matrix
        stress_strain % [2x1] stress -> strain constants
        R % [12x12] rotation matrix from element to global reference frame
    end
    
    %% solution
    properties
        force % [12 x nm] element forces in element reference frame
        stress % [8 x nm] element longitudinal stresses [[C1 D1 E1 F1 C2 D2 E2 F2] x nm]
        strain % [8 x nm x 2] element longitudinal and transverse strains [[C1 D1 E1 F1 C2 D2 E2 F2] x nm x 2], where strain(:,:,1) are longitudinal strains and strain(:,:,2) are transverse strains
        eke % [nm x 1] Element modal kinetic energy
        ese % [nm x 1] Element static or modal strain energy
    end
    
    methods
        %%
        function obj = initialize(obj,data)
            obj.EID  = set_data('CBEAM','EID',data{2},'int',[],1);
            obj.PID  = set_data('CBEAM','PID',data{3},'int',[],1);
            obj.GA   = set_data('CBEAM','GA',data{4},'dec',[]);
            obj.GB   = set_data('CBEAM','GB',data{5},'dec',[]);
            obj.X1   = set_data('CBEAM','X1',data{6},'dec',[]);
            obj.X2   = set_data('CBEAM','X2',data{7},'dec',[]);
            obj.X3   = set_data('CBEAM','X3',data{8},'dec',[]);
        end
        
        function echo(obj,fid)
            fprintf(fid,'CBEAM,%d,%d,%d,%d,%f,%f,%f\n',obj.EID,obj.PID,obj.GA,obj.GB,obj.X1,obj.X2,obj.X3);
        end
    end
end
