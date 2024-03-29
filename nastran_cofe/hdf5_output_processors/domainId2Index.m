% Function to convert the HDF5 DOMAIN_ID vector to an INDEX dataset structure
% Anthony Ricciardi
function indexStruct = domainId2Index(domainID)

[uniqueDomainId,position] = unique(domainID);
nUnique = size(uniqueDomainId,1);

indexStruct.DOMAIN_ID = uniqueDomainId;
indexStruct.POSITION = int64(position-1);
indexStruct.LENGTH = zeros(size(uniqueDomainId),'int64');
for i = 1:nUnique-1
    indexStruct.LENGTH(i)=indexStruct.POSITION(i+1)-indexStruct.POSITION(i);
end
indexStruct.LENGTH(end)=size(domainID,1)-indexStruct.POSITION(end);