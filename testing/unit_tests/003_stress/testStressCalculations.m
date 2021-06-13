% clearvars; close all; clc
% addpath(genpath(fullfile('..','..','..','nastran_cofe')));

data2D = readtable('twoDimensionalReferece.csv','HeaderLines',1);
stress2D = [data2D.s1,data2D.s2,data2D.s12].';

data3D = readtable('threeDimensionalReferece.csv','HeaderLines',1);
stress3D = [data3D.s11,data3D.s22,data3D.s33,data3D.s23,data3D.s13,data3D.s12].';

%% vonMises2D
vonMises2D = calculateVonMises(stress2D);
differenceVonMises2D = calculateNormalizedDifference(vonMises2D.',data2D.sVonMises);
assert(all(differenceVonMises2D<1e-6),'Failed comparison')

%% vonMises3D
vonMises3D = calculateVonMises(stress3D);
differenceVonMises3D = calculateNormalizedDifference(vonMises3D.',data3D.sVonMises);
assert(all(differenceVonMises3D<1e-6),'Failed comparison')

%% principal2D
[sMajPrin2D,sMinPrin2D,angle2D] = calculatePrincipal(stress2D);

differenceMajPrin2D = calculateNormalizedDifference(sMajPrin2D.',data2D.sMajPrin);
assert(all(differenceMajPrin2D<1e-5),'Failed comparison')

differenceMinPrin2D = calculateNormalizedDifference(sMinPrin2D.',data2D.sMinorPrin);
assert(all(differenceMinPrin2D<1e-5),'Failed comparison')

differenceAngle2D = calculateNormalizedDifference(angle2D.',data2D.sAngle);
assert(all(differenceAngle2D<1e-5),'Failed comparison')
