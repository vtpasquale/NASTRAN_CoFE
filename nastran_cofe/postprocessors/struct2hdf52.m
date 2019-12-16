% Function write a Matlab struct to an HDF5 dataset
function struct2hdf5(file,dataset,structData)

% The struct fields must be nx1 arrays of limited type. Dimension n must be
% consistent.

% based on h5ex_t_cmpd
%**************************************************************************
%
%  This example shows how to read and write compound
%  datatypes to a dataset.  The program first writes
%  compound structures to a dataset with a dataspace of DIM0,
%  then closes the file.  Next, it reopens the file, reads
%  back the data, and outputs it to the screen.
%
%  This file is intended for use with HDF5 Library version 1.8
%**************************************************************************

% fileName       = 'h5ex_t_cmpd.h5';
% dataset        = 'DS1';
% DIM0           = 4;
% nFields = DIM0;

%
% Initialize data. It is more efficient to use Structures with array fields
% than arrays of structures.
%
% structData.serial_no   =int32([1153 ; 1184 ; 1027  ;    1313]);
% structData.location    ={'Exterior (static)', 'Intake','Intake manifold', 'Exhaust manifold'};
% structData.temperature =[53.23; 55.12; 130.55; 1252.89];
% structData.pressure    =[24.57; 22.95;  31.23;   84.11];

%% Native type sizes
intType   =H5T.copy('H5T_NATIVE_INT');
intSize   =H5T.get_size(intType);

strType  = H5T.copy ('H5T_C_S1');
H5T.set_size (strType,'H5T_VARIABLE');
strSize   =H5T.get_size(strType);

doubleType=H5T.copy('H5T_NATIVE_DOUBLE');
doubleSize=H5T.get_size(doubleType);

%% structData field data
fieldNames = fieldnames(structData);
nFields = size(fieldNames,1);
fieldDataSize = zeros(nFields,1);
fieldDataType = zeros(nFields,1);
fieldColumSize = zeros(nFields,1);
for i = 1:nFields
    fieldData = structData.(fieldNames{i});
    
    % field data checks
    [nfieldData,mfieldData]=size(fieldData);
    fieldColumSize(i) = nfieldData;
    if mfieldData~=1; error('mfieldData~=1'); end
        
    % Type assignment
    if isa(fieldData,'double')
        fieldDataSize(i) = doubleSize;
        fieldDataType(i) = doubleType;
    elseif isa(fieldData,'int32')
        fieldDataSize(i) = intSize;
        fieldDataType(i) = intType;
    elseif isa(fieldData,'int64')
        fieldDataSize(i) = intSize;
        fieldDataType(i) = intType;
        structData.(fieldNames{i}) = int32(fieldData);
    elseif isa(fieldData,'cell')
        fieldDataSize(i) = strSize; % TODO: check cell contents, or restrict to numeric data
        fieldDataType(i) = strType;
    else
        error('Data type unsupported')
    end
end

% check consistency
if size(unique(fieldColumSize),1)~=1
    error('The input struct contains fields with inconsistent array sizes.')
end

%% Create a new file using the default properties.
% file = H5F.create (fileName, 'H5F_ACC_TRUNC','H5P_DEFAULT', 'H5P_DEFAULT');

%
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
% H5T.insert (memtype,'location',offset(2), strType);
% H5T.insert (memtype,'temperature',offset(3), doubleType);
% H5T.insert (memtype,'pressure',offset(4), doubleType);

%
% Create the compound datatype for the file.  Because the standard
% types we are using for the file may have different sizes than
% the corresponding native types, we must manually calculate the
% offset of each member.
%
filetype = H5T.create ('H5T_COMPOUND', sumFieldDataSize);
for i = 1:nFields
    H5T.insert(filetype,fieldNames{i},offset(i),fieldDataType(i));
end
% H5T.insert (filetype, 'serial_no', offset(1),intType);
% H5T.insert (filetype, 'location', offset(2), strType);
% H5T.insert (filetype, 'temperature',offset(3), doubleType);
% H5T.insert (filetype, 'pressure',offset(4), doubleType);


%
% Create dataspace.  Setting maximum size to [] sets the maximum
% size to be the current size.
%
H5S_UNLIMITED = H5ML.get_constant_value('H5S_UNLIMITED');
space = H5S.create_simple(1,fieldColumSize(1),H5S_UNLIMITED);

dcpl = H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(dcpl,fieldColumSize(1));

%
% Create the dataset and write the compound data to it.
%
dset = H5D.create (file, dataset, filetype, space,dcpl);
H5D.write (dset, memtype, 'H5S_ALL', 'H5S_ALL', 'H5P_DEFAULT', structData);

%
% Close and release resources.
%
H5D.close (dset);
H5S.close (space);
H5T.close (filetype);
% H5F.close (file);
