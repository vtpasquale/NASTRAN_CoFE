%Hdf5Summary Abstract superclass for MSC Nastran HDF5 summary data.

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
            if size(obj,1)
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
        
        function hdf5Summary = constructFromCofe(solution)
            % Function to solution output data to HDF5 summary
            %
            % INPUTS
            % solution [nSubcases,nSuperElements Solution]
            hdf5Summary = [];
            nSubcases=size(solution,1);
            for i = 1:nSubcases
                if isa(solution(i,1),'ModesSolution') || isa(solution(i,1),'BuckSolution')
                    hdf5SummaryNext = Hdf5SummaryEigenvalue(solution(i,1));
                    if isempty(hdf5Summary)
                        hdf5Summary=hdf5SummaryNext;
                    else
                        hdf5Summary = hdf5Summary.append(hdf5SummaryNext);
                    end
                end
            end
        end
    end
    methods (Sealed = true, Access = private)
        function obj=append(obj,hdf5SummaryNext)
            nObj = size(obj,1);
            nextMetaClass = metaclass(hdf5SummaryNext);
            for i = 1:nObj
                if isa(obj(i),nextMetaClass.Name)
                    obj(i) = obj(i).appendObj(hdf5SummaryNext);
                    return
                end
            end
            % Only gets here if this is a new element type
            obj = [obj;hdf5SummaryNext];
        end
    end
end