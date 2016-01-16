% Class for CBEAM entries
% Anthony Ricciardi
%
classdef cbeam < structure & static_recover

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
        
        kdp     % [12x12] element unit-load differential stiffness matricies in global reference frame
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
        R % [12x12] rotation matrix from element to global reference frame
    end
    
    %% solution
    properties
        force % [12x1] element forces in element reference frame
        stress % [] element stresses
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
