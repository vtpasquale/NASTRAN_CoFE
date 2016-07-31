% Initialize CoFE fem object for optimization
% Anthony Ricciardi
%
% Inputs
% inputFile  - [string] name of NASTRAN-formatted bulk data input file
% CASE - [1x#subcases case_obj] array of objects containing case control data
%
% Output
% FEM0 - [1x1 fem] Initial finite element model inputs all subcases as CASE
%
function FEM0 = CoFE_design_initialize(inputFile,CASE)

%% Instantiate FEM object and read model data from input file
FEM0 = importModel(inputFile);
FEM0.CASE = CASE;

end

