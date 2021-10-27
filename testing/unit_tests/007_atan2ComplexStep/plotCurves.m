clear all; close all; clc

n = 100;
x = -1*ones(n,1);
y = linspace(-1,1,n).';
ty = atan2(y,x);
[dtdy,dtdx]=gradatan2(y,x);

plot(y,ty,y,dtdy,y,dtdx)
grid on