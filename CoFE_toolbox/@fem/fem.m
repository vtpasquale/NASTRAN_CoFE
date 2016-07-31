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
        applied_loadList = {};
    end
    
    %% Executive and Case Control Properties
    properties
        CASE;
    end
    
    %% Entry/finite element object arrays - see class files for complete description
    properties
        BLIQ@bliq;
        CBEAM@cbeam;
        CELAS2@celas2;
        CMASS1@cmass1;
        CONM2@conm2;
        CORD2R@cord2r;
        CQUAD4@cquad4;
        CROD@crod;
        EIGRL@eigrl;
        FORCE@force;
        GRAV@grav;
        GRDSET@grdset;
        GRID@grid_obj; % special naming (grid_obj) because 'grid' name overlaps with MATLAB plotting functionality
        LOAD@load_obj; % special naming (load_obj) because 'load' name overlaps with MATLAB built-in function
        MAT1@mat1;
        MOMENT@moment;
        PBEAM@pbeam;
        PBEAML@pbeaml;
        PMASS@pmass;
        PROD@prod;
        PSHELL@pshell;
        RBE2@rbe2;
        RBE3@rbe3;
        SPC1@spc1;
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
        u    % [ndof,ND] static deformation, vibration eigenvectors, or buckling eigenvectors
        fHz  % [ND,1] sqrt(eVal)/(2*pi) - vibration frequency for SOL - 103
        eVal % [ND,1] eigenvalues
    end
end


