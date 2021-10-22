function complexModel = seletiveAssembleProperties(complexModel,analysisModel,selectPid)
% Selective Model assembly, reduction. Can be used in place of Model.assemble()
% for some sizing optimization problems. Only elements linked to a specific
% property ID are assembled.
%
% Inputs
% complexModel  [Model] model with complex perturbations for design variables
% analysisModel [Model] baseline analysis model
% selectPid [uint32] Property identification number for selective assembly
%
% Outputs
% complexModel [Model] - model with complex perturbations after assembly

% Anthony Ricciardi
% October 2021

[nModel,mModel]=size(complexModel);
if nModel~=1; error('This function does not support superelements.'); end
if mModel~=1; error('This function only operates on Model arrays size 1 x 1.'); end

% Selective assembly  [Model.assemble_sub()]
elementPids = [complexModel.element.pid].';
recalculateFlag = elementPids==selectPid;

% Fully assemble elements that are affected by design varaiables
selectElements = complexModel.element(recalculateFlag);
complexModelSelect = selectElements.assemble(complexModel);

% Apply select assembly data to model
complexModel.element(recalculateFlag) = complexModelSelect.element;
complexModel.K_gg=complexModelSelect.K_gg;
complexModel.M_gg=complexModelSelect.M_gg;

% Reuse elements (no complex perturbations) that are unaffected by design
% variables. This data still needs to be included for element recovery.
complexModel.element(~recalculateFlag) = analysisModel.element(~recalculateFlag);

% No change to MPC and load assembly (reusing data will not work for all
% design variable types.)
% complexModel.mpcs = analysisModel.mpcs;
% complexModel.load = analysisModel.load;
complexModel = complexModel.mpcs.assemble(complexModel);
complexModel = complexModel.load.assemble(complexModel);

% No change to MPC partitioning
complexModel(1) = complexModel(1).mpcPartition();

% No change to reduce residual structure
complexModel(1).reducedModel = ReducedModel.constructFromModel(complexModel(1));