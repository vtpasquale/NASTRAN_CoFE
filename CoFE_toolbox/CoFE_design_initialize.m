% Initialize CoFE fem object for optimization
% Anthony Ricciardi
%
%  Input
%  CASE - structure varable containing executive and case control data
%      .inputFile [string] name of NASTRAN-formatted bulk data input file
%      .SOL [int] solution sequence (101, 103, or 105)
%      .SPC [int] identification number of single-point constraint set
%      .LOAD [int] identification number of load set
%      .METHOD [int] identification number of eigenpair solution method
%      .RECOVER [bool] element staic solution data recovery option
%           = 1 recover element static solution quantities (e.g. stress, internal force)
%           = 0 skip element data recovery
%         Notes:
%           Default = 1
%           Element staic solution data always recovered when CASE.SOL=105.
%      .WRITE_c06 [bool] text output file (.c06) option
%           = 1 write .c06 output file
%           = 0 skip writing output file
%         Notes:
%           Will be set to zero before saving to FEM.CASE.WRITE_c06
%
% Output
% FEM - [1x1 fem] Finite element model and solution object
%
function FEM = CoFE_design_initialize(CASE)

%% Instantiate FEM object and read model data from input file
FEM = importModel(CASE.inputFile);

%% Write CASE structure FEM object (this must be done after FEM object is instantiated)
FEM.CASE = CASE;

end

