% Function to execute CoFE analysis
% Anthony Ricciardi
%
%  Inputs
%  inputFile  - [string] name of NASTRAN-formatted bulk data input file
%  CASE - [1x#subcases case_obj] array of objects containing case control data
%
% Output
% FEM - [1x#subcases fem] Array of finite element model and solution objects
%
function FEM = CoFE_analysis(inputFile,CASE)

%% Instantiate FEM object and read model data from input file
FEM0 = importModel(inputFile);
FEM0.CASE = CASE;

%% Assemble array of subcases
FEM = assemble(FEM0,CASE);

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

% %% Write output file
% if isfield(CASE,'WRITE_c06')==0; CASE.WRITE_c06=1; end
% if CASE.WRITE_c06 == 1
%     FEM.write_c06(CASE.inputFile);
% end

end

