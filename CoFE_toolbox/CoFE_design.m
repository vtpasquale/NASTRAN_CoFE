% Function to execute CoFE analysis
% Anthony Ricciardi
%
% Input
% FEM = [1x1 fem] Finite element model and solution object
% X = [ndvx1 real] vector of design variables
% X_2_FEM = [function handle] function to update FEM object based on design variable values 
%
% Outputs
% FEM = [1x1 fem] Finite element model and solution object
% FEM_prime = [1xnumber of design variables fem] FEM object array with model and solution design derivatives
%
function [FEM,FEM_prime] = CoFE_design(FEM,X,X_2_FEM)

if nargout < 2 % no design derivatives
    FEM = update_design(FEM,X,X_2_FEM);
    
    %% Solve array of subcases
    for sc = 1:size(FEM,2)
        switch FEM(sc).CASE.SOL
            case 101
                FEM(sc) = FEM(sc).analysis_101();
            case 103
                FEM(sc) = FEM(sc).analysis_103();
            case 105
                FEM(sc) = FEM(sc).analysis_105( FEM(FEM(sc).CASE.REF_LC) );
            otherwise
                error('FEM.CASE.SOL should be set to 101, 103, or 105.')
        end
    end
    
else % with design derivatives
    [FEM, FEM_prime] = FEM.update_design(X,X_2_FEM);
        
    %% Solve array of subcases
    ndv = size(X,1); % number of design varaibles
    nsc = size(FEM,2); % number of subcases
    for sc = 1:nsc
        switch FEM(sc).CASE.SOL
            case 101
                [FEM(sc),FEM_prime(1:ndv,sc)] = FEM(sc).analysis_101(FEM_prime(1:ndv,sc));
            case 103
                [FEM(sc),FEM_prime(1:ndv,sc)] = FEM(sc).analysis_103(FEM_prime(1:ndv,sc));
            case 105
                [FEM(sc),FEM_prime(1:ndv,sc)] = FEM(sc).analysis_105(...
                    FEM(FEM(sc).CASE.REF_LC), FEM_prime(1:ndv,sc), FEM_prime(1:ndv,FEM(sc).CASE.REF_LC));
            otherwise
                error('FEM.CASE.SOL should be set to 101, 103, or 105.')
        end
    end    
    
end

end

