classdef fem
    % Defines a complete finite element model and solution
    %
    % Anthony Ricciardi
    % Aug 2015

    %% Input data format
    properties (Constant = true)
        entryList = {'BLIQ','CBEAM','CMASS1','CONM2','CORD2R','CQUAD4','CROD','EIGRL','FORCE','GRAV',...
            'GRDSET','GRID','MAT1','PBEAM','PBEAML','PMASS','PROD','PSHELL','SPC1','RBE2','RBE3'};
        constraintList = {'RBE3','RBE2'};
        elementList = {'BLIQ','CBEAM','CMASS1','CONM2','CQUAD4','CROD'};
        plotList = {'BLIQ','CBEAM','CMASS1','CONM2','CQUAD4','CROD','RBE2'};
        recoverList = {'BLIQ','CBEAM','CQUAD4','CROD'};
    end
    
    %% Executive and Case Control Properties
    properties
        CASE
    end
    
    %% Entry/finite element object arrays - see class files for complete description
    properties
        BLIQ@bliq
        GRID@grid;
        GRDSET@grdset;
        CBEAM@cbeam;
        CQUAD4@cquad4;
        CORD2R@cord2r;
        MAT1@mat1;
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


