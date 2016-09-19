% Class for CBEAM entries 
% Anthony Ricciardi
%
classdef cbeam < structure & plot1D

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
    properties (GetAccess = public, SetAccess = private)
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
    properties (SetAccess = private, GetAccess = ?plot1D)
        x1    % [3x1] node 1 position
        x2    % [3x1] node 2 position
    end
    properties (Access = private)
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
    properties (Dependent=true)
        voigtStress % [6 x nm x 8] Matrix of stress vectors in Voigt notation [[s11 s22 s33 s23 s13 s12]' x nm x [C1 D1 E1 F1 C2 D2 E2 F2]], where nm is the number of response modes.
        voigtStrain % [6 x nm x 8] Matrix of strain vectors in Voigt notation [[e11 e22 e33 e23 e13 e12]' x nm x [C1 D1 E1 F1 C2 D2 E2 F2]], where nm is the number of response modes.
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
        
        %%
        function echo(obj,fid)
            fprintf(fid,'CBEAM,%d,%d,%d,%d,%f,%f,%f\n',obj.EID,obj.PID,obj.GA,obj.GB,obj.X1,obj.X2,obj.X3);
        end
        
        %% Get functions
        function out = get.voigtStress(obj)
            if isempty(obj.stress)
                out = [];
            else
                nm = size(obj.stress,2);
                voigtStress =zeros(6,nm,8);
                for m = 1:nm
                    voigtStress(1,m,1)=obj.stress(1,m);
                    voigtStress(1,m,2)=obj.stress(2,m);
                    voigtStress(1,m,3)=obj.stress(3,m);
                    voigtStress(1,m,4)=obj.stress(4,m);
                    voigtStress(1,m,5)=obj.stress(5,m);
                    voigtStress(1,m,6)=obj.stress(6,m);
                    voigtStress(1,m,7)=obj.stress(7,m);
                    voigtStress(1,m,8)=obj.stress(8,m);
                end
                out=voigtStress;
            end
        end
        
        function out = get.voigtStrain(obj)
            if isempty(obj.strain)
                out = [];
            else
                nm = size(obj.strain,2);
                voigtStrain =zeros(6,nm,8);
                for m = 1:nm
                    voigtStrain(1,m,1)=obj.strain(1,m,1); voigtStrain(2:3,m,1)=obj.strain(1,m,2);
                    voigtStrain(1,m,2)=obj.strain(2,m,1); voigtStrain(2:3,m,2)=obj.strain(2,m,2);
                    voigtStrain(1,m,3)=obj.strain(3,m,1); voigtStrain(2:3,m,3)=obj.strain(3,m,2);
                    voigtStrain(1,m,4)=obj.strain(4,m,1); voigtStrain(2:3,m,4)=obj.strain(4,m,2);
                    voigtStrain(1,m,5)=obj.strain(5,m,1); voigtStrain(2:3,m,5)=obj.strain(5,m,2);
                    voigtStrain(1,m,6)=obj.strain(6,m,1); voigtStrain(2:3,m,6)=obj.strain(6,m,2);
                    voigtStrain(1,m,7)=obj.strain(7,m,1); voigtStrain(2:3,m,7)=obj.strain(7,m,2);
                    voigtStrain(1,m,8)=obj.strain(8,m,1); voigtStrain(2:3,m,8)=obj.strain(8,m,2);
                end
                out=voigtStrain;
            end
        end
        
    end
end
