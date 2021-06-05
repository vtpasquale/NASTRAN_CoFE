%Hdf5ElementStrain Abstract superclass for MSC Nastran HDF5 format element strain output data.

% A. Ricciardi
% June 2021

classdef (Abstract) Hdf5ElementStrain < Hdf5CompoundDataset & matlab.mixin.Heterogeneous

%     properties  (Abstract) % Can't make properties abstract and constant
%         DATASET
%     end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/ELEMENTAL/STRAIN/';
    end
    methods (Abstract)
        constructFromElementOutputData(elementOutputData)
    end
    methods (Sealed = true)
        function export(obj,dataGroup,indexGroup)
            if size(obj,1)>0
                % create element strain result groups
                objDataGroup  = H5G.create(dataGroup,'STRAIN','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                objIndexGroup = H5G.create(indexGroup,'STRAIN','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                
                nObj = size(obj,1);
                for i = 1:nObj
                    obj(i).export_sub(objDataGroup,objIndexGroup)
                end
                
                % close groups
                H5G.close(objDataGroup);
                H5G.close(objIndexGroup);
            end
        end
        function compare(obj1,obj2,obj2index,compareExponent)
            % Function to compare objects
            
            % sort metaclass types
            for i = 1:size(obj1,1)
                metaClass1=metaclass(obj1(i));
                className1{i} = metaClass1.Name;
            end
            for i = 1:size(obj2,1)
                metaClass2=metaclass(obj2(i));
                className2{i} = metaClass2.Name;
            end
            
            % loop over types
            for i = 1:size(obj1,1)
                j = find(strcmp(className1{i},className2));
                if length(j)~=1; error('Issue with result type identification for comparison.'); end
                compareCompoundDataset(obj1(i),obj2(j),obj2index,compareExponent)
            end
            
        end
    end
    methods (Static = true)
        function hdf5ElementStrain = constructFromFile(filename)
            info = h5info(filename,Hdf5ElementStrain.GROUP);
            nDatasets = size(info.Datasets,1);
            ii = 0;
            for i = 1:nDatasets
                
                % convert dataset name to case-sensitive class name
                entryName =  lower(info.Datasets(i).Name);
                entryName(1) = upper(entryName(1));
                
                % check that input entry is supported
                if exist(['Hdf5ElementStrain',entryName],'class')==8
                    % Call contructor method for each entry
                    ii = ii + 1;
                    eval(['hdf5ElementStrain(ii,1) = Hdf5ElementStrain',entryName,'(filename);']);
                else
                    warning('Hdf5 element strain entry %s not supported.',upper(entryName))
                end
            end
        end
        function hdf5ElementStrain = constructFromCofe(model,solution)
            % Creates Hdf5ElementStrain object from CoFE data
            %
            % INPUTS
            % model [nSuperElements,1 Model]
            % solution [nSubcases,nSuperElements Solution]
            %
            % OUTPUTS
            % hdf5ElementStrain = [Hdf5ElementStrain] element strain output data in HDF5 format class
            hdf5ElementStrain=[];
            [nSubcases,nSuperElements]=size(solution);
            for i = 1:nSubcases
                for j = 1:nSuperElements
                    
                    % Domain IDs
                    domainIDs = solution(i,j).vectorHdf5DomainID.'; % [nResponseVectors,1 uint32] HDF5 output file Domain ID or each respone vector
                    
                    % Process element strain data
                    elementOutputData=solution(i,j).strain;
                    if ~isempty(elementOutputData)
                        elementTypes = [elementOutputData.elementType];
                        uniqueElementTypes=unique(elementTypes);
                        nElementTypes=size(uniqueElementTypes,2);
                        for typeIndex = 1:nElementTypes
                            dataIndicies = elementTypes==uniqueElementTypes(typeIndex);
                            data = elementOutputData(dataIndicies);
                            elementObject = model(j).element(data(1).elementID==model(j).elementEIDs);                            
                            hdf5ElementStrainConstructor = str2func(elementObject.HDF5_STRAIN_CLASSNAME);
                            hdf5ElementStrainNext = hdf5ElementStrainConstructor(data,domainIDs);
                            if isempty(hdf5ElementStrain)
                                hdf5ElementStrain=hdf5ElementStrainNext;
                            else
                                hdf5ElementStrain = hdf5ElementStrain.append(hdf5ElementStrainNext);
                            end
                        end
                    end
                end
            end
        end
    end
    methods (Sealed = true, Access = private)
        function obj=append(obj,hdf5ElementStrainNext)
            nObj = size(obj,1);
            nextMetaClass = metaclass(hdf5ElementStrainNext);
            for i = 1:nObj
                if isa(obj(i),nextMetaClass.Name)
                    obj(i) = obj(i).appendObj(hdf5ElementStrainNext);
                    return
                end
            end
            % Only gets here if this is a new element type
            obj = [obj;hdf5ElementStrainNext];
        end
    end
end