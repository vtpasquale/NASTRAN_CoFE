%Hdf5Nodal Abstract superclass for MSC Nastran HDF5 format node/point output data.

% A. Ricciardi
% December 2019

classdef (Abstract) Hdf5Nodal < Hdf5CompoundDataset & matlab.mixin.Heterogeneous
    
%     properties  (Abstract) % Can't make properties abstract and constant
%         DATASET
%     end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/NODAL/';
    end
%     methods (Static = true)
%         function obj = Hdf5Nodal(arg1)
%             % no class constructor for abstract classes
%         end
%     end
    methods (Sealed = true)
        function export(obj,dataGroup,indexGroup)
            if size(obj,1)>0
                % create element result groups
                objDataGroup  = H5G.create(dataGroup ,'NODAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                objIndexGroup = H5G.create(indexGroup,'NODAL','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                
                nObj = size(obj,1);
                for i = 1:nObj
                    obj(i).export_sub(objDataGroup,objIndexGroup)
                end
                
                % close groups
                H5G.close(objDataGroup);
                H5G.close(objIndexGroup);
            end
        end
    end
    methods (Static = true)
        function hdf5Nodal = constructFromFile(filename)
            hdf5Nodal = Hdf5Nodal.empty();
            info = h5info(filename,Hdf5Nodal.GROUP);
            nDatasets = size(info.Datasets,1);
            ii = 0;
            for i = 1:nDatasets
                
                % convert dataset name to case-sensitive class name
                resultName =  lower(info.Datasets(i).Name);
                resultName(1) = upper(resultName(1));
                
                % check that input entry is supported
                if exist(['Hdf5Nodal',resultName],'class')==8
                    % Call contructor method for each entry
                    ii = ii + 1;
                    eval(['hdf5Nodal(ii,1) = Hdf5Nodal',resultName,'(filename);']);
                else
                    warning('Hdf5 element nodal result %s not supported.',upper(resultName))
                end
            end            
        end
    end
end

