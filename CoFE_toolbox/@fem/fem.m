% Defines a complete finite element model and solution
% Anthony Ricciardi
%
classdef fem

    %% Type lists - to be defined based on class metadata
    properties
        entryList = {};
        elementList = {};
        structureList = {};
        constraintList = {};
        static_recoverList = {};
        applied_loadList = [];
    end
    
    %% Executive and Case Control Properties
    properties
        CASE
    end
    
    %% Entry/finite element object arrays - see class files for complete description
    properties
        BLIQ@bliq;
        GRID@grid_obj; % special naming (grid_obj) because 'grid' name overlaps with MATLAB plotting functionality
        GRDSET@grdset;
        CBEAM@cbeam;
        CQUAD4@cquad4;
        CORD2R@cord2r;
        LOAD@load_obj; % special naming (load_obj) because 'load' name overlaps with MATLAB built-in function
        MAT1@mat1;
        MOMENT@moment;
        PBEAM@pbeam;
        PBEAML@pbeaml;
        PSHELL@pshell;
        SPC1@spc1;
        FORCE@force;
        GRAV@grav;
        PROD@prod;
        CROD@crod;
        EIGRL@eigrl;
        PMASS@pmass;
        CMASS1@cmass1;
        CONM2@conm2;
        RBE2@rbe2;
        RBE3@rbe3;
        CELAS2@celas2;
    end

    %% Global finite element model properties
    properties
        nnodes
        ndof
        gcoord
        gnum2gdof
        gnum
        s
        f
        m
        n
        nf_g
        nf_n
        p
        K_G
        M_G
        KD_G
        Gm
        ND   % [scalar] number of desired roots (eigenpairs)
    end
    
    %% Global finite element solution properties
    properties
        x
        xm   % [ndof,ND] vibration eigenvectors
        wHz  % [ND,1]vibration frequencies (Hz)
        xb
        Db
    end
end


