% Class for CROD entries
% A tension-compression-torsion element
% Anthony Ricciardi
%
classdef crod < structure
    
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
        stress_strain % [2x1] stress -> strain constants
        R % [12x12] rotation matrix from element to global reference frame
    end
    
    %% solution
    properties
        force % [nm x 1] element static or modal axial force
        stress % [nm x 1] static or modal longitudinal (s11) stresses
        strain % [nm x 1 x 2] static or modal longitudinal and transverse strains where strain(:,:,1) are longitudinal strains and strain(:,:,2) are transverse strains
        eke % [nm x 1] element modal kinetic energy
        ese % [nm x 1] element static or modal strain energy
    end
    properties (Dependent=true)
        voigtStress % [6 x nm] Matrix of stress vectors in Voigt notation [[s11 s22 s33 s23 s13 s12]' x nm ], where nm is the number of response modes.
        voigtStrain % [6 x nm] Matrix of strain vectors in Voigt notation [[s11 s22 s33 s23 s13 s12]' x nm ], where nm is the number of response modes.
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
        
        %% Get functions
        function out = get.voigtStress(obj)
            if isempty(obj.stress)
                out = [];
            else
                out=[obj.stress.';zeros(5,size(obj.stress,1))];
            end
        end
        function out = get.voigtStrain(obj)
            if isempty(obj.strain)
                out = [];
            else
                out=[obj.strain(1).';obj.strain(2).';obj.strain(2).';zeros(3,size(obj.strain,1))];
            end
        end
    end
    
end
