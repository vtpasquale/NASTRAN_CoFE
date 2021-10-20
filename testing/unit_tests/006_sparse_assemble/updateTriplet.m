function [i,j,s,nTripletsNew] = updateTriplet(i,j,s,nTripletsOld,M,gDof)
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

[iM,jM,m]=find(M);

% Number management
nTripletsNew = nTripletsOld + size(m,1);
while nTripletsNew > size(s,1)
    [i,j,s] = padVectors(i,j,s);
end

% Add values to triplets
index = nTripletsOld+1:nTripletsNew;
i(index) = gDof(iM);
j(index) = gDof(jM);
s(index) = m;
end

function [i,j,s] = padVectors(i,j,s)
% Doubles the size of triplet vectors by padding with zeros
paddedLength = 2*size(s,1);
i(paddedLength,1) = uint32(0);
j(paddedLength,1) = uint32(0);
s(paddedLength,1) = 0;
end