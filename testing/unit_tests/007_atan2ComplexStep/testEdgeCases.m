clear all; close all; clc

% edge cases
X = [1 -1 0 1 -1  0  1 -1];
Y = [0  0 1 1  1 -1 -1 -1];


T = atan2ComplexStep(Y,X);
TM = atan2(Y,X);
[T;TM]

% analytic
[dtdy,dtdx]=gradatan2(Y,X); 

% finite difference
dfd = 1e5*eps;
fddy = atan2(Y+dfd,X);
fdDtdy = (fddy-TM)./dfd;
fddx = atan2(Y,X+dfd);
fdDtdx = (fddx-TM)./dfd;

% complex step
dcs = 1e2*eps;
csdy = atan2ComplexStep(Y+1i*dcs,X);
csDtdy = imag(csdy)./dcs;
csdx = atan2ComplexStep(Y,X+1i*dcs);
csDtdx = imag(csdx)./dcs;

[dtdy;fdDtdy;csDtdy]
[dtdx;fdDtdx;csDtdx]



