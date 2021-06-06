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
        function obj = importCompoundDatasetFromHdf5File(obj,datasetString)
            % Imports the dataset from an HDF5 file. And converts  struct
            % data from h5read to properties of the specific dataset class
            % instance.
            obj.version = h5readatt(datasetString,[obj.GROUP,obj.DATASET],'version');
%             if obj.version ~= obj.SCHEMA_VERSION
%                 metaClass = metaclass(obj); warning('Imported %s dataset schema version number is different than the dataset schema version used for CoFE development.',metaClass.Name)
%             end
                
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
        function obj = appendObj(obj1,obj2)
            % Appends the object data with data from another object
            obj2Struct = getStruct(obj2);
            obj = appendStruct(obj1,obj2Struct);
        end
        function objTable = getTable(obj)
            % Creates a MATLAB table from the H5T_COMPOUND data.
            objStruct=getStruct(obj);
            objTable=struct2table(objStruct);
        end
        function compareCompoundDataset(obj1,obj2,obj2index,compareExponent)
           % Compare HDF5 compound dataset objects. Used to mainly to verify CoFE solutions.
           % INPUTS
           % obj1 [Hdf5CompoundDataset] result one (typically CoFE result)
           % obj2 [Hdf5CompoundDataset] result one (typically Nastran result)
           % obj2index [n,1 uint32] sorted index for consistent HDF5 domains
           % compareExponent [n,1 double] exponent used for comparing signed data (any data type double). Square when comparing eigenvector data to avoid sign issues.
           
           obj1Struct = getStruct(obj1);
           obj2Struct = getStruct(obj2);
           
           % Print what is being compared (consider commenting this out)
           fprintf(1,'Comparing %s%s\n' ,obj1.GROUP,obj1.DATASET)
           
           % loop over domain IDS
           uniqueDomainIDs = unique(obj1Struct.DOMAIN_ID);
           for i = 1:size(uniqueDomainIDs,1)
               index1 = uniqueDomainIDs(i)==obj1Struct.DOMAIN_ID;
               index2 = obj2index(uniqueDomainIDs(i))==obj2Struct.DOMAIN_ID;
               compareExponentI = compareExponent(uniqueDomainIDs(i));
               % loop over field names
               fnLoop=fieldnames(rmfield(obj1Struct,{'DOMAIN_ID'}))';
               for fn = fnLoop
                   comparisonFailed = false;
                   
                   result1 = obj1.(fn{1});
                   result2 = obj2.(fn{1});
                   
                   % Manage multidimensional results
                   if size(result1,2)>1
                       result1DomainI = result1(:,index1);
                       result2DomainI = result2(:,index2);
                   else
                       result1DomainI = result1(index1);
                       result2DomainI = result2(index2);
                   end
                   
                   % Type management
                   if isa(result1,'double')
                       normalizedDifference=calculateNormalizedDifference(...
                           result1DomainI.^compareExponentI,result2DomainI.^compareExponentI);
                       if any(any(abs(normalizedDifference)>0.01))
                           comparisonFailed = true;
                           fprintf(1,'Domain ID: %d\n',uniqueDomainIDs(i))
                           fprintf(1,'Result: %s\n',fn{1})
                           normalizedDifference
                           [result1DomainI,result2DomainI,result1DomainI.^compareExponentI,result2DomainI.^compareExponentI]
                       end
                   elseif isinteger(result1)
                       if any(any(result1DomainI~=result2DomainI))
                           comparisonFailed = true;
                       end
                   else
                       error('Data type unsupported')
                   end
                   
                   % Error if comparison failed
                   if comparisonFailed
                       % [result1DomainI,result2DomainI]
                       metaClass = metaclass(obj1);
                       warning('HDF5 comparison failed for Class %s Property %s',metaClass.Name,fn{1})
                   end
               end
           end
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