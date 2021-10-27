function [dtdy,dtdx]=gradatan2(Y,X)
dtdx=-Y./(X.^2+Y.^2);
dtdy= X./(X.^2+Y.^2);