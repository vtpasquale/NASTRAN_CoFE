clear all; close all; clc

% random case
Y = 2*rand(3,4,2)-1;
X = 2*rand(3,4,2)-1;

T = atan2ComplexStep(Y,X);
TM=atan2(Y,X);
TM-T

% derivative check
dcs = 1e2*eps;
dfd = 1e5*eps;
[dtdy,dtdx]=gradatan2(Y,X); % analytic

csdy = atan2ComplexStep(Y+1i*dcs,X);
csDtdy = imag(csdy)./dcs;
csdx = atan2ComplexStep(Y,X+1i*dcs);
csDtdx = imag(csdx)./dcs;


fddy = atan2(Y+dfd,X);
fdDtdy = (fddy-TM)./dfd;
fddx = atan2(Y,X+dfd);
fdDtdx = (fddx-TM)./dfd;

