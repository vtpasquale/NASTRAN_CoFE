%Hdf5ElementEnergy Abstract superclass for MSC Nastran HDF5 format element energy output data.

% This could work as well without being an abstract class. Keeping it abstract for consistentcy.
% A. Ricciardi
% December 2019

classdef (Abstract) Hdf5ElementEnergy < Hdf5CompoundDataset & matlab.mixin.Heterogeneous

%     properties  (Abstract) % Can't make properties abstract and constant
%         DATASET
%     end
    properties (Constant = true)
        GROUP = '/NASTRAN/RESULT/ELEMENTAL/ENERGY/';
    end
    methods (Abstract)
        constructFromElementOutputData(elementOutputData)
    end
    methods (Sealed = true)
        function export(obj,dataGroup,indexGroup)
            if size(obj,1)>0
                % create element energy result groups
                objDataGroup  = H5G.create(dataGroup,'ENERGY','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                objIndexGroup = H5G.create(indexGroup,'ENERGY','H5P_DEFAULT','H5P_DEFAULT','H5P_DEFAULT');
                
                nObj = size(obj,1);
                for i = 1:nObj
                    obj(i).export_sub(objDataGroup,objIndexGroup)
                end
                
                % close groups
                H5G.close(objDataGroup);
                H5G.close(objIndexGroup);
            end
        end
        function compare(obj1,obj2,obj2index)
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
                j = find(strcmp(className1,className2{i}));
                if length(j)~=1; error('Issue with result type identification for comparison.'); end
                compareCompoundDataset(obj1(i),obj2(j),obj2index)
            end
            
        end
    end
    methods (Static = true)
        function hdf5ElementEnergy = constructFromFile(filename)
            info = h5info(filename,Hdf5ElementEnergy.GROUP);
            nDatasets = size(info.Datasets,1);
            ii = 0;
            for i = 1:nDatasets
                
                % convert dataset name to case-sensitive class name
                entryName =  lower(info.Datasets(i).Name);
                entryName(1) = upper(entryName(1));
                
                % check that input entry is supported
                if exist(['Hdf5ElementEnergy',entryName],'class')==8
                    % Call contructor method for each entry
                    ii = ii + 1;
                    eval(['hdf5ElementEnergy(ii,1) = Hdf5ElementEnergy',entryName,'(filename);']);
                else
                    warning('Hdf5 element energy entry %s not supported.',upper(entryName))
                end
            end
        end
        function hdf5ElementEnergy = constructFromCofe(model,solution)
            % Creates Hdf5ElementEnergy object from CoFE data
            %
            % INPUTS
            % model [nSuperElements,1 Model]
            % solution [nSubcases,nSuperElements Solution]
            %
            % OUTPUTS
            % hdf5ElementEnergy = [Hdf5ElementEnergy] element energy output data in HDF5 format class
            hdf5ElementEnergy=[];
            [nSubcases,nSuperElements]=size(solution);
            for i = 1:nSubcases
                for j = 1:nSuperElements
                                        
                    % Domain IDs
                    domainIDs = solution(i,j).vectorHdf5DomainID.'; % [nResponseVectors,1 uint32] HDF5 output file Domain ID or each respone vector
                    
                    % Solution Output Data
                    strainEnergyOutputData=solution(i,j).ese;
                    kineticEnergyOutputData=solution(i,j).eke;
                                        
                    % Strain energy
                    if ~isempty(strainEnergyOutputData)
                        hdf5ElementEnergyStrain_elemNext = Hdf5ElementEnergyStrain_elem(strainEnergyOutputData,domainIDs);
                        
                        if isempty(hdf5ElementEnergy)
                            hdf5ElementEnergy=hdf5ElementEnergyStrain_elemNext;
                        else
                            hdf5ElementEnergy = hdf5ElementEnergy.append(hdf5ElementEnergyStrain_elemNext);
                        end
                    end
                    
                    % Kinetic energy
                    if ~isempty(kineticEnergyOutputData)
                        hdf5ElementEnergyKinetic_elem = Hdf5ElementEnergyKinetic_elem(kineticEnergyOutputData,domainIDs);
                        
                        if isempty(hdf5ElementEnergy)
                            hdf5ElementEnergy=hdf5ElementEnergyKinetic_elem;
                        else
                            hdf5ElementEnergy = hdf5ElementEnergy.append(hdf5ElementEnergyKinetic_elem);
                        end
                    end
                    
                end
            end
        end
    end
    methods (Sealed = true, Access = private)
        function obj=append(obj,hdf5ElementForceNext)
            nObj = size(obj,1);
            nextMetaClass = metaclass(hdf5ElementForceNext);
            for i = 1:nObj
                if isa(obj(i),nextMetaClass.Name)
                    obj(i) = obj(i).appendObj(hdf5ElementForceNext);
                    return
                end
            end
            % Only gets here if this is a new element type
            obj = [obj;hdf5ElementForceNext];
        end
    end
end