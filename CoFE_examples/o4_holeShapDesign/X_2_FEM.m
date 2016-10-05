% Function to apply specifed design to finite element model data
% User must customize this function for each problem
%
% Inputs:
% x = (number of design variables x 1) vector of design variables
% 
% Outputs
% FEM [Cell Structured Data] finite element model data for current design
%
function FEM = X_2_FEM(FEM,X)

% User supplied design data
BV = FEM.designData.BV;
nind = FEM.designData.nind;

% Apply shape design
for n = 1:size(nind,1)
    FEM.GRID(n).X1 = FEM.designData.GRID(n).X1 + BV(nind(n,1),:)*X;
    FEM.GRID(n).X2 = FEM.designData.GRID(n).X2 + BV(nind(n,2),:)*X;
end

end
