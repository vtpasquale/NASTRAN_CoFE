%Hdf5ElementForce Abstract superclass for MSC Nastran HDF5 format element force output data.

% A. Ricciardi
% December 2019

classdef (Abstract) Hdf5ElementForce < Hdf5CompoundDataset & matlab.mixin.Heterogeneous

%     properties  (Abstract) % Can't make properties abstract and constant
%         DATASET
%     end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/ELEMENTAL/ELEMENT_FORCE/';
    end
    methods
        function export(obj,dataGroup,indexGroup)
            % create element force result groups
            objDataGroup  = H5G.create(dataGroup,'ELEMENT_FORCE','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            objIndexGroup = H5G.create(indexGroup,'ELEMENT_FORCE','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            
            nObj = size(obj,1);
            for i = 1:nObj
                obj(i).export_sub(objDataGroup,objIndexGroup)
            end
            
            % close groups
            H5G.close(objDataGroup);
            H5G.close(objIndexGroup);
        end
    end
    methods (Static = true)
        function hdf5ElementForce = constructFromFile(filename)
            info = h5info(filename,Hdf5ElementForce.GROUP);
            nDatasets = size(info.Datasets,1);
            for i = 1:nDatasets
                
                % convert field 1 to case-sensitive class name
                entryName =  lower(info.Datasets(i).Name);
                entryName(1) = upper(entryName(1));
                
                % check that input entry is supported
                if exist(['Hdf5ElementForce',entryName],'class')==8
                    % Call contructor method for each entry
                    eval(['hdf5ElementForce(i,1) = Hdf5ElementForce',entryName,'(filename);']);
                else
                    warning('Hdf5 element force entry %s not supported.',upper(entryName))
                end
            end
        end
    end
    
end

