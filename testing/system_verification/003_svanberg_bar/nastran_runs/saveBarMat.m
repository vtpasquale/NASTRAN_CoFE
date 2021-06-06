clear all; close all; clc
setunits('in')

f = readnas('barmat.pch','blocks','');
k = convertMatrixStructureToFull(f.matrix(1),12);
m = convertMatrixStructureToFull(f.matrix(2),12);
save barMatrices.mat k m

function matrix = convertMatrixStructureToFull(matrixStruct,n)

d1 = double(matrixStruct.dof{1});
d2 = double(matrixStruct.dof{2});
dof1 = 6*( d1(:,1)-1) + d1(:,2);
dof2 = 6*( d2(:,1)-1) + d2(:,2);

matrix = zeros(n);
matrix(dof1,dof2) = matrixStruct.matrix;
end