% Function writes numeric struct data to an HDF5 dataset as H5T_COMPOUND.
% Designed to help create MSC Nastran format HDF5 output files. 
%
% INPUTS
% locationID [H5ML.id] HDF5 location identifier
% datasetName [char] dataset name
% structData [struct] Data to be written as type H5T_COMPOUND to the HDF5 
%                     location. All fields must contain [n,m numeric] data. 
%                     Dimension n must be consistent, but m can vary.
% version [int64] Optional. Attribute 'version' to be written.
%
% OUTPUTS: Void
%
function struct2hdf5(locationID,datasetName,structData,version)

% Initialize types and sizes
intType   =H5T.copy('H5T_STD_I64LE');
intSize   =H5T.get_size(intType);

doubleType=H5T.copy('H5T_IEEE_F64LE');
doubleSize=H5T.get_size(doubleType);

% structData field data
fieldNames = fieldnames(structData);
nFields = size(fieldNames,1);
fieldDataSize = zeros(nFields,1);
fieldDataType(nFields,1) = H5ML.id; % this is not a double, so don't initialize as double. It's type H5ML.id
fieldColumSize = zeros(nFields,1);
fieldRowSize = ones(nFields,1);
for i = 1:nFields
    fieldData = structData.(fieldNames{i});
    
    % field data checks
    [nfieldData,mfieldData]=size(fieldData);
    
    if mfieldData~=1
        % for multidimensional field data
        fieldColumSize(i) = mfieldData;
        fieldRowSize(i) = nfieldData;
    else
        fieldColumSize(i) = nfieldData;
    end
    
    % Type assignment
    if isa(fieldData,'double')
        fieldDataType(i) = doubleType;
        fieldDataSize(i) = doubleSize;
    elseif isa(fieldData,'int32')
        fieldDataType(i) = intType;
        fieldDataSize(i) = intSize;
        structData.(fieldNames{i}) = int64(fieldData);
    elseif isa(fieldData,'int64')
        fieldDataType(i) = intType;
        fieldDataSize(i) = intSize;
    else
        error('Data type unsupported')
    end
    
    % overwrite for array datatype
    if fieldRowSize(i)~=1
        fieldDataType(i) = H5T.array_create(fieldDataType(i),fieldRowSize(i));
        fieldDataSize(i) = H5T.get_size(fieldDataType(i));
    end
end

% check consistency
if size(unique(fieldColumSize),1)~=1
    error('The input struct contains fields with inconsistent array sizes.')
end

% Compute the offsets to each field. The first offset is always zero.
offset=zeros(nFields,1);
offset(2:end)=cumsum(fieldDataSize(1:end-1));

%
% Create the compound datatype for memory.
%
sumFieldDataSize=sum(fieldDataSize);
memtype = H5T.create ('H5T_COMPOUND', sumFieldDataSize);
for i = 1:nFields
    H5T.insert(memtype,fieldNames{i},offset(i),fieldDataType(i));    
end

H5S_UNLIMITED = H5ML.get_constant_value('H5S_UNLIMITED');
space = H5S.create_simple(1,fieldColumSize(1),H5S_UNLIMITED);

dcpl = H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(dcpl,fieldColumSize(1));

% Create the dataset and write the compound data to it.
dset = H5D.create (locationID, datasetName, memtype, space,dcpl);
H5D.write(dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', structData);

% version attribute
if nargin > 3
    acpl_id = H5P.create('H5P_ATTRIBUTE_CREATE');
    type_id = H5T.copy('H5T_STD_I64LE');
    space_id = H5S.create_simple(1,1,1);
    attr_id = H5A.create(dset,'version',type_id,space_id,acpl_id);
    H5A.write(attr_id,'H5ML_DEFAULT',version)
    H5A.close(attr_id);
end

% Close and release resources.
H5D.close(dset);
H5P.close(dcpl)
H5S.close(space);
H5T.close(memtype);