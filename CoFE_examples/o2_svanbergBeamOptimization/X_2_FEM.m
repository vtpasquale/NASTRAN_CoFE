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
t = 0.062/21.483152759999999;  
FEM.PBEAM(1).I2 = 2.*t.*X(1,1).^3./3;
FEM.PBEAM(2).I2 = 2.*t.*X(2,1).^3./3;
FEM.PBEAM(3).I2 = 2.*t.*X(3,1).^3./3;
FEM.PBEAM(4).I2 = 2.*t.*X(4,1).^3./3;
FEM.PBEAM(5).I2 = 2.*t.*X(5,1).^3./3;
end
