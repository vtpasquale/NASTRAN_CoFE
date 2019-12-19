% Abstract superclass for HDF5 datasets of type H5T_COMPOUND

% A. Ricciardi
% December 2019

classdef (Abstract) Hdf5CompoundDataset
    
    properties
        version % dataset version
    end
    %     properties
    %         % A property must be created for each H5T_COMPOUND data member
    %     end
    %     properties (Constant = true) % Can't make properties abstract and constant
    %         GROUP
    %         DATASET
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
            fieldData = h5read(datasetString,[obj.GROUP,obj.DATASET]);
            for fn = fieldnames(fieldData)'    %enumerat fields
                obj.(fn{1}) = fieldData.(fn{1});   % copy to object properties
            end
            obj.version = h5readatt(datasetString,[obj.GROUP,obj.DATASET],'version');
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
            objStruct=rmfield(objStruct,{'GROUP','DATASET','version'});
        end
        function export_sub(obj,dataGroup,indexGroup)
            % Exports the dataset to an HDF5 file.
            objStruct=getStruct(obj);
            struct2hdf52(dataGroup,obj.DATASET,objStruct,obj.version)
            
            indexStruct = domainId2Index(obj.DOMAIN_ID);
            struct2hdf52(indexGroup,obj.DATASET,indexStruct);
        end
    end
end