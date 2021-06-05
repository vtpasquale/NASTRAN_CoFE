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
        function hdf5Nodal = constructFromCofe(solution)
            % Creates Hdf5Nodal object from CoFE data
            %
            % INPUTS
            % solution [nSubcases,nSuperElements Solution]
            %
            % OUTPUTS
            % hdf5Nodal = [Hdf5Nodal] Node output data in HDF5 format class
            hdf5Nodal=[];
            [nSubcases,nSuperElements]=size(solution);
            for i = 1:nSubcases
                for j = 1:nSuperElements
                    
                    % Domain IDs
                    domainIDs = solution(i,j).vectorHdf5DomainID.'; % [nResponseVectors,1 uint32] HDF5 output file Domain ID or each respone vector
                    
                    % Displacements/Eigenvectors
                    nodeDisplacementData=solution(i,j).displacement;
                    if ~isempty(nodeDisplacementData)
                        if isa(solution(i,j),'ModesSolution')
                            hdf5NodalNext = Hdf5NodalEigenvector();
                        else
                            hdf5NodalNext = Hdf5NodalDisplacement();
                        end
                        hdf5NodalNext = hdf5NodalNext.constructFromNodeOutputData(nodeDisplacementData,domainIDs);
                        if isempty(hdf5Nodal)
                            hdf5Nodal = hdf5NodalNext;
                        else
                            hdf5Nodal = hdf5Nodal.append(hdf5NodalNext);
                        end
                    end
                    
                    % SPC_FORCE
                    nodeSpcForceData=solution(i,j).spcforces;
                    if ~isempty(nodeSpcForceData)
                        hdf5NodalNext = Hdf5NodalSpc_force();
                        hdf5NodalNext = hdf5NodalNext.constructFromNodeOutputData(nodeSpcForceData,domainIDs);
                        if isempty(hdf5Nodal)
                            hdf5Nodal = hdf5NodalNext;
                        else
                            hdf5Nodal = hdf5Nodal.append(hdf5NodalNext);
                        end
                    end
                    
                end
            end
        end
    end
    
    methods (Access = private)
        function obj = constructFromNodeOutputData(obj,nodeOutputData,domainIDs)
            % Function to convert node eigenvector output data to HDF5
            %
            % INPUTS
            % nodeOutputData [nNodes,1 NodeOutputData] node output data
            % domainIDs [nVectors,1 unit32] HDF5 domain ID numbers
            %
            nNodes = size(nodeOutputData.ID,1);
            nVectors = size(nodeOutputData(1).T1,2);
            obj.ID = repmat(nodeOutputData.ID,[nVectors,1]);
            obj.X = nodeOutputData.T1(:);
            obj.Y = nodeOutputData.T2(:);
            obj.Z = nodeOutputData.T3(:);
            obj.RX = nodeOutputData.R1(:);
            obj.RY = nodeOutputData.R2(:);
            obj.RZ = nodeOutputData.R3(:);
            domainMatrix = repmat(domainIDs,[nNodes,1]);
            obj.DOMAIN_ID = domainMatrix(:);
            obj.version = obj.SCHEMA_VERSION;
        end
    end
    methods (Sealed = true, Access = private)
        function obj=append(obj,hdf5NodalNext)
            nObj = size(obj,1);
            nextMetaClass = metaclass(hdf5NodalNext);
            for i = 1:nObj
                if isa(obj(i),nextMetaClass.Name)
                    obj(i) = obj(i).appendObj(hdf5NodalNext);
                    return
                end
            end
            % Only gets here if this is a new node response type
            obj = [obj;hdf5NodalNext];
        end
    end
    
end

