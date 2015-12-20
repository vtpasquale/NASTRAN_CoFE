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
FEM.PROD(1).A = X(1);
FEM.PROD(2).A = X(2);
FEM.PROD(3).A = X(3);
FEM.PROD(4).A = X(4);
FEM.PROD(5).A = X(5);
FEM.PROD(6).A = X(6);
FEM.PROD(7).A = X(7);
FEM.PROD(8).A = X(8);
FEM.PROD(9).A = X(9);
FEM.PROD(10).A = X(10);

FEM.GRID(1).X1 = 720 + X(11);
FEM.GRID(1).X3 = X(12);
FEM.GRID(3).X1 = 360 + X(13);
FEM.GRID(3).X3 = X(14);
end
