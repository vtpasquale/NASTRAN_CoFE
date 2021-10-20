function [i,j,s,nTriplets] = initializeTriplet(paddedLength)
% Function for assembling sparse matrices as triplets
%
% nTriplets [uint32] Number of triplets
% i [paddedLength, 1 uint32] row indices
% j [paddedLength, 1 uint32] column indices
% s [paddedLength, 1 double] matrix values
% M [n,n double] square matrix to add to triplet
% gDof [nDof,1 uint32] global indicies of square matrix

% Anthony Ricciardi
% October 2021

i = zeros(paddedLength,1,'uint32');
j = i;
s = zeros(paddedLength,1,'double');
nTriplets = uint32(0);
end