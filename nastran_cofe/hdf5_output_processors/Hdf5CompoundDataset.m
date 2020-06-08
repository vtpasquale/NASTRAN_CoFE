% Abstract superclass for HDF5 datasets of type H5T_COMPOUND.
% Designed to work with MSC Nastran format HDF5 output files. 

% A. Ricciardi
% December 2019

classdef (Abstract) Hdf5CompoundDataset
    
    properties
        version % MSC dataset schema version
    end
    %     properties
    %         % A property must be created for each H5T_COMPOUND data member
    %     end
    %     properties (Constant = true) % Can't make properties abstract and constant
    %         GROUP
    %         DATASET
    %         SCHEMA_VERSION; % MSC dataset schema version used for CoFE development
    %     end
    methods (Abstract)
        % Export the dataset to an HDF5 file.
        export(obj,file)
    end
    methods
        function obj = import(obj,datasetString)
            % Imports the dataset from an HDF5 file. And converts  struct
            % data from h5read to properties of the specific dataset class
            % instance.
            obj.version = h5readatt(datasetString,[obj.GROUP,obj.DATASET],'version');
            if obj.version ~= obj.SCHEMA_VERSION
                metaClass = metaclass(obj); warning('Imported %s dataset schema version number is different than the dataset schema version used for CoFE development.',metaClass.Name)
            end
                
            fieldData = h5read(datasetString,[obj.GROUP,obj.DATASET]);
            for fn = fieldnames(fieldData)'    %enumerat fields
                obj.(fn{1}) = fieldData.(fn{1});   % copy to object properties
            end
            
        end
        function obj = appendStruct(obj,structData)
            % Appends the object with structure data. The field names
            % must match the nonconstant object properties.
            for fn = fieldnames(structData)'     %enumerat fields
                obj.(fn{1}) = [obj.(fn{1});structData.(fn{1})]; % append object properties
            end
        end
        function objTable = getTable(obj)
            % Creates a MATLAB table from the H5T_COMPOUND data.
            objStruct=getStruct(obj);
            objTable=struct2table(objStruct);
        end
    end
    methods (Access = protected)
        function objStruct = getStruct(obj)
            % Creates a MATLAB struct from the H5T_COMPOUND data.
            warning('off','MATLAB:structOnObject')
            objStruct=struct(obj);
            warning('on','MATLAB:structOnObject')
            objStruct=rmfield(objStruct,{'GROUP','DATASET','SCHEMA_VERSION','version'});
        end
        function export_sub(obj,dataGroup,indexGroup)
            % Exports the dataset to an HDF5 file.
            objStruct=getStruct(obj);
            struct2hdf5(dataGroup,obj.DATASET,objStruct,obj.version)
            
            indexStruct = domainId2Index(obj.DOMAIN_ID);
            struct2hdf5(indexGroup,obj.DATASET,indexStruct);
        end
    end
end