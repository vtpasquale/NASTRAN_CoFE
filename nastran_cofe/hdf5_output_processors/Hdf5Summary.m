%Hdf5Nodal Abstract superclass for MSC Nastran HDF5 format output summary data.

% A. Ricciardi
% Jan 2020

classdef (Abstract) Hdf5Summary < Hdf5CompoundDataset & matlab.mixin.Heterogeneous
    
%     properties  (Abstract) % Can't make properties abstract and constant
%         DATASET
%     end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/SUMMARY/';
    end
%     methods (Static = true)
%         function obj = Hdf5Summary(arg1)
%             % no class constructor for abstract classes
%         end
%     end
    methods (Sealed = true)
        function export(obj,dataGroup,indexGroup)
            
            % create element result groups
            objDataGroup  = H5G.create(dataGroup ,'SUMMARY','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            objIndexGroup = H5G.create(indexGroup,'SUMMARY','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
            
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
        function hdf5Summary = constructFromFile(filename)
            hdf5Summary = Hdf5Summary.empty();
            info = h5info(filename,Hdf5Summary.GROUP);
            nDatasets = size(info.Datasets,1);
            ii = 0;
            for i = 1:nDatasets
                
                % convert dataset name to case-sensitive class name
                resultName =  lower(info.Datasets(i).Name);
                resultName(1) = upper(resultName(1));
                
                % check that input entry is supported
                if exist(['Hdf5Summary',resultName],'class')==8
                    % Call contructor method for each entry
                    ii = ii + 1;
                    eval(['hdf5Summary(ii,1) = Hdf5Summary',resultName,'(filename);']);
                else
                    warning('Hdf5 summary result %s not supported.',upper(resultName))
                end
            end            
        end
    end
end

